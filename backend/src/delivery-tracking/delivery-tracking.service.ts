import { Injectable, Logger, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Socket } from 'socket.io';
import { RiderLocation, Delivery, Rider, DeliveryStatus } from '../entities';

interface ClientSubscription {
  clientId: string;
  deliveryId: number;
  userId: number;
  userType: 'sender' | 'receiver';
}

@Injectable()
export class DeliveryTrackingService {
  private logger: Logger = new Logger('DeliveryTrackingService');
  private clientSubscriptions: Map<string, ClientSubscription[]> = new Map();

  constructor(
    @InjectRepository(RiderLocation)
    private riderLocationRepository: Repository<RiderLocation>,
    @InjectRepository(Delivery)
    private deliveryRepository: Repository<Delivery>,
    @InjectRepository(Rider)
    private riderRepository: Repository<Rider>,
  ) {}

  // Add client subscription
  addClientSubscription(
    clientId: string,
    deliveryId: number,
    userId: number,
    userType: 'sender' | 'receiver'
  ) {
    const subscription: ClientSubscription = {
      clientId,
      deliveryId,
      userId,
      userType,
    };

    const existingSubscriptions = this.clientSubscriptions.get(clientId) || [];
    existingSubscriptions.push(subscription);
    this.clientSubscriptions.set(clientId, existingSubscriptions);

    this.logger.log(`Added subscription for client ${clientId}: delivery ${deliveryId}, user ${userId} (${userType})`);
  }

  // Remove client subscription
  removeClientSubscription(clientId: string, deliveryId: number) {
    const subscriptions = this.clientSubscriptions.get(clientId) || [];
    const filteredSubscriptions = subscriptions.filter(sub => sub.deliveryId !== deliveryId);
    this.clientSubscriptions.set(clientId, filteredSubscriptions);

    this.logger.log(`Removed subscription for client ${clientId}: delivery ${deliveryId}`);
  }

  // Remove all client subscriptions (on disconnect)
  removeClientSubscriptions(clientId: string) {
    const subscriptions = this.clientSubscriptions.get(clientId) || [];
    subscriptions.forEach(sub => {
      this.logger.log(`Cleaning up subscription for client ${clientId}: delivery ${sub.deliveryId}`);
    });
    this.clientSubscriptions.delete(clientId);
  }

  // Update rider location
  async updateRiderLocation(riderId: number, latitude: number, longitude: number): Promise<RiderLocation> {
    // Verify rider exists
    const rider = await this.riderRepository.findOne({ where: { rider_id: riderId } });
    if (!rider) {
      throw new NotFoundException('Rider not found');
    }

    // Upsert rider location
    const existingLocation = await this.riderLocationRepository.findOne({
      where: { rider_id: riderId }
    });

    if (existingLocation) {
      existingLocation.latitude = latitude;
      existingLocation.longitude = longitude;
      return this.riderLocationRepository.save(existingLocation);
    } else {
      const newLocation = this.riderLocationRepository.create({
        rider_id: riderId,
        latitude,
        longitude,
      });
      return this.riderLocationRepository.save(newLocation);
    }
  }

  // Update delivery status
  async updateDeliveryStatus(
    deliveryId: number,
    riderId: number,
    status: string,
    imageUrl?: string
  ): Promise<Delivery> {
    const delivery = await this.deliveryRepository.findOne({
      where: { delivery_id: deliveryId },
      relations: ['rider']
    });

    if (!delivery) {
      throw new NotFoundException('Delivery not found');
    }

    if (delivery.rider_id !== riderId) {
      throw new BadRequestException('Rider is not assigned to this delivery');
    }

    // Validate status transition
    const validStatuses = Object.values(DeliveryStatus);
    if (!validStatuses.includes(status as DeliveryStatus)) {
      throw new BadRequestException(`Invalid status: ${status}`);
    }

    const newStatus = status as DeliveryStatus;

    // Validate status transition
    const validTransitions = {
      [DeliveryStatus.ACCEPTED]: [DeliveryStatus.IN_TRANSIT],
      [DeliveryStatus.IN_TRANSIT]: [DeliveryStatus.DELIVERED],
    };

    if (delivery.status !== DeliveryStatus.WAITING &&
        !validTransitions[delivery.status]?.includes(newStatus)) {
      throw new BadRequestException(`Invalid status transition from ${delivery.status} to ${newStatus}`);
    }

    // Update delivery status
    delivery.status = newStatus;

    // Update image URL based on status
    if (newStatus === DeliveryStatus.IN_TRANSIT && imageUrl) {
      delivery.in_transit_image_url = imageUrl;
    } else if (newStatus === DeliveryStatus.DELIVERED && imageUrl) {
      delivery.delivered_image_url = imageUrl;
    }

    return this.deliveryRepository.save(delivery);
  }

  // Send current delivery state to client
  async sendCurrentDeliveryState(client: Socket, deliveryId: number) {
    try {
      const delivery = await this.deliveryRepository.findOne({
        where: { delivery_id: deliveryId },
        relations: ['rider', 'sender', 'receiver', 'pickup_address', 'delivery_address']
      });

      if (!delivery) {
        client.emit('error', { message: 'Delivery not found', deliveryId });
        return;
      }

      // Send current delivery info
      client.emit('delivery-state', {
        delivery: {
          delivery_id: delivery.delivery_id,
          status: delivery.status,
          package_details: delivery.package_details,
          pickup_image_url: delivery.pickup_image_url,
          in_transit_image_url: delivery.in_transit_image_url,
          delivered_image_url: delivery.delivered_image_url,
          sender: delivery.sender ? {
            user_id: delivery.sender.user_id,
            name: delivery.sender.name,
            phone_number: delivery.sender.phone_number,
          } : null,
          receiver: delivery.receiver ? {
            user_id: delivery.receiver.user_id,
            name: delivery.receiver.name,
            phone_number: delivery.receiver.phone_number,
          } : null,
          pickup_address: delivery.pickup_address ? {
            address_id: delivery.pickup_address.address_id,
            address_line: delivery.pickup_address.address_line,
            latitude: delivery.pickup_address.latitude,
            longitude: delivery.pickup_address.longitude,
          } : null,
          delivery_address: delivery.delivery_address ? {
            address_id: delivery.delivery_address.address_id,
            address_line: delivery.delivery_address.address_line,
            latitude: delivery.delivery_address.latitude,
            longitude: delivery.delivery_address.longitude,
          } : null,
          rider: delivery.rider ? {
            rider_id: delivery.rider.rider_id,
            name: delivery.rider.name,
            phone_number: delivery.rider.phone_number,
          } : null,
        },
        timestamp: new Date().toISOString(),
      });

      // Send current rider location if available
      if (delivery.rider_id) {
        const riderLocation = await this.riderLocationRepository.findOne({
          where: { rider_id: delivery.rider_id }
        });

        if (riderLocation) {
          client.emit('rider-location-update', {
            deliveryId,
            riderId: delivery.rider_id,
            latitude: riderLocation.latitude,
            longitude: riderLocation.longitude,
            timestamp: riderLocation.updated_at.toISOString(),
          });
        }
      }
    } catch (error) {
      this.logger.error(`Error sending delivery state for delivery ${deliveryId}:`, error);
      client.emit('error', { message: 'Failed to get delivery state', deliveryId });
    }
  }
}
