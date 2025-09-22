import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Delivery, User, Address, Rider, RiderLocation, DeliveryStatus } from '../entities';

@Injectable()
export class DeliveriesService {
  constructor(
    @InjectRepository(Delivery)
    private deliveryRepository: Repository<Delivery>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Address)
    private addressRepository: Repository<Address>,
    @InjectRepository(Rider)
    private riderRepository: Repository<Rider>,
    @InjectRepository(RiderLocation)
    private riderLocationRepository: Repository<RiderLocation>,
  ) {}

  // Create a new delivery
  async createDelivery(deliveryData: {
    sender_id: number;
    receiver_id: number;
    pickup_address_id: number;
    delivery_address_id: number;
    package_details?: string;
  }): Promise<Delivery> {
    const { sender_id, receiver_id, pickup_address_id, delivery_address_id, package_details } = deliveryData;

    // Verify sender exists
    const sender = await this.userRepository.findOne({ where: { user_id: sender_id } });
    if (!sender) {
      throw new NotFoundException('Sender not found');
    }

    // Verify receiver exists
    const receiver = await this.userRepository.findOne({ where: { user_id: receiver_id } });
    if (!receiver) {
      throw new NotFoundException('Receiver not found');
    }

    // Verify addresses exist and belong to the correct users
    const pickupAddress = await this.addressRepository.findOne({
      where: { address_id: pickup_address_id, user_id: sender_id }
    });
    if (!pickupAddress) {
      throw new BadRequestException('Pickup address not found or does not belong to sender');
    }

    const deliveryAddress = await this.addressRepository.findOne({
      where: { address_id: delivery_address_id, user_id: receiver_id }
    });
    if (!deliveryAddress) {
      throw new BadRequestException('Delivery address not found or does not belong to receiver');
    }

    // Create delivery
    const delivery = this.deliveryRepository.create({
      sender_id,
      receiver_id,
      pickup_address_id,
      delivery_address_id,
      package_details,
    });

    return this.deliveryRepository.save(delivery);
  }

  // Get deliveries sent by a user
  async getSentDeliveries(userId: number): Promise<Delivery[]> {
    // Verify user exists
    const user = await this.userRepository.findOne({ where: { user_id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.deliveryRepository.find({
      where: { sender_id: userId },
      relations: ['receiver', 'pickup_address', 'delivery_address', 'rider'],
      order: { created_at: 'DESC' },
    });
  }

  // Get deliveries received by a user
  async getReceivedDeliveries(userId: number): Promise<Delivery[]> {
    // Verify user exists
    const user = await this.userRepository.findOne({ where: { user_id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.deliveryRepository.find({
      where: { receiver_id: userId },
      relations: ['sender', 'pickup_address', 'delivery_address', 'rider'],
      order: { created_at: 'DESC' },
    });
  }

  // Get rider location for a delivery
  async getDeliveryRiderLocation(deliveryId: number): Promise<RiderLocation | null> {
    const delivery = await this.deliveryRepository.findOne({
      where: { delivery_id: deliveryId },
      relations: ['rider']
    });

    if (!delivery) {
      throw new NotFoundException('Delivery not found');
    }

    if (!delivery.rider_id) {
      return null; // No rider assigned yet
    }

    return this.riderLocationRepository.findOne({
      where: { rider_id: delivery.rider_id }
    });
  }

  // Get delivery by ID
  async getDeliveryById(deliveryId: number): Promise<Delivery> {
    const delivery = await this.deliveryRepository.findOne({
      where: { delivery_id: deliveryId },
      relations: ['sender', 'receiver', 'pickup_address', 'delivery_address', 'rider']
    });

    if (!delivery) {
      throw new NotFoundException('Delivery not found');
    }

    return delivery;
  }

  // Get all available deliveries (waiting status)
  async getAvailableDeliveries(): Promise<Delivery[]> {
    return this.deliveryRepository.find({
      where: { status: DeliveryStatus.WAITING },
      relations: ['sender', 'receiver', 'pickup_address', 'delivery_address'],
      order: { created_at: 'ASC' },
    });
  }
}
