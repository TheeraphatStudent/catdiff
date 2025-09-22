import { Injectable, NotFoundException, ConflictException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Rider, RiderLocation, Delivery, DeliveryStatus } from '../entities';

@Injectable()
export class RidersService {
  constructor(
    @InjectRepository(Rider)
    private riderRepository: Repository<Rider>,
    @InjectRepository(RiderLocation)
    private riderLocationRepository: Repository<RiderLocation>,
    @InjectRepository(Delivery)
    private deliveryRepository: Repository<Delivery>,
  ) {}

  // Get rider by ID
  async findRiderById(riderId: number): Promise<Rider> {
    const rider = await this.riderRepository.findOne({ where: { rider_id: riderId } });
    if (!rider) {
      throw new NotFoundException('Rider not found');
    }
    return rider;
  }

  // Update rider location
  async updateRiderLocation(
    riderId: number,
    locationData: { latitude: number; longitude: number }
  ): Promise<RiderLocation> {
    await this.findRiderById(riderId); // Verify rider exists

    // Upsert rider location (insert or update)
    const existingLocation = await this.riderLocationRepository.findOne({
      where: { rider_id: riderId }
    });

    if (existingLocation) {
      existingLocation.latitude = locationData.latitude;
      existingLocation.longitude = locationData.longitude;
      return this.riderLocationRepository.save(existingLocation);
    } else {
      const newLocation = this.riderLocationRepository.create({
        rider_id: riderId,
        ...locationData,
      });
      return this.riderLocationRepository.save(newLocation);
    }
  }

  // Get rider's current location
  async getRiderLocation(riderId: number): Promise<RiderLocation | null> {
    await this.findRiderById(riderId); // Verify rider exists
    return this.riderLocationRepository.findOne({ where: { rider_id: riderId } });
  }

  // Check if rider has active delivery
  async hasActiveDelivery(riderId: number): Promise<boolean> {
    const activeDelivery = await this.deliveryRepository.findOne({
      where: {
        rider_id: riderId,
        status: DeliveryStatus.ACCEPTED
      }
    });
    return !!activeDelivery;
  }

  // Accept delivery
  async acceptDelivery(riderId: number, deliveryId: number): Promise<Delivery> {
    await this.findRiderById(riderId); // Verify rider exists

    const delivery = await this.deliveryRepository.findOne({ where: { delivery_id: deliveryId } });
    if (!delivery) {
      throw new NotFoundException('Delivery not found');
    }

    if (delivery.status !== 'waiting') {
      throw new BadRequestException('Delivery is not available for acceptance');
    }

    // Check if rider already has an active delivery
    const hasActive = await this.hasActiveDelivery(riderId);
    if (hasActive) {
      throw new ConflictException('Rider can only accept one delivery at a time');
    }

    // Accept the delivery
    delivery.rider_id = riderId;
    delivery.status = DeliveryStatus.ACCEPTED;

    return this.deliveryRepository.save(delivery);
  }

  // Update delivery status
  async updateDeliveryStatus(
    riderId: number,
    deliveryId: number,
    newStatus: DeliveryStatus,
    locationData?: { latitude: number; longitude: number }
  ): Promise<Delivery> {
    await this.findRiderById(riderId); // Verify rider exists

    const delivery = await this.deliveryRepository.findOne({
      where: { delivery_id: deliveryId },
      relations: ['pickup_address', 'delivery_address']
    });

    if (!delivery) {
      throw new NotFoundException('Delivery not found');
    }

    if (delivery.rider_id !== riderId) {
      throw new BadRequestException('Rider is not assigned to this delivery');
    }

    // Validate status transition
    const validTransitions = {
      [DeliveryStatus.ACCEPTED]: [DeliveryStatus.IN_TRANSIT],
      [DeliveryStatus.IN_TRANSIT]: [DeliveryStatus.DELIVERED],
    };

    if (!validTransitions[delivery.status]?.includes(newStatus)) {
      throw new BadRequestException(`Invalid status transition from ${delivery.status} to ${newStatus}`);
    }

    // Distance validation if location provided
    if (locationData) {
      const targetLocation = newStatus === DeliveryStatus.IN_TRANSIT
        ? delivery.pickup_address
        : delivery.delivery_address;

      const distance = this.calculateDistance(
        locationData.latitude,
        locationData.longitude,
        targetLocation.latitude,
        targetLocation.longitude
      );

      if (distance > 20) { // 20 meters
        throw new BadRequestException('Rider must be within 20 meters of the target location');
      }
    }

    // Update delivery status
    delivery.status = newStatus;

    return this.deliveryRepository.save(delivery);
  }

  // Calculate distance between two coordinates (in meters)
  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371e3; // Earth's radius in meters
    const φ1 = (lat1 * Math.PI) / 180;
    const φ2 = (lat2 * Math.PI) / 180;
    const Δφ = ((lat2 - lat1) * Math.PI) / 180;
    const Δλ = ((lon2 - lon1) * Math.PI) / 180;

    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
  }
}
