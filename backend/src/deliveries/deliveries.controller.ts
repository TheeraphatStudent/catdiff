import { Controller, Get, Post, Body, Param, ParseIntPipe, UseGuards } from '@nestjs/common';
import { DeliveriesService } from './deliveries.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('deliveries')
@UseGuards(JwtAuthGuard)
export class DeliveriesController {
  constructor(private readonly deliveriesService: DeliveriesService) {}

  // Create a new delivery
  @Post()
  async createDelivery(@Body() deliveryData: {
    sender_id: number;
    receiver_id: number;
    pickup_address_id: number;
    delivery_address_id: number;
    package_details?: string;
  }) {
    return this.deliveriesService.createDelivery(deliveryData);
  }

  // Get rider location for a delivery
  @Get(':id/rider-location')
  async getRiderLocation(@Param('id', ParseIntPipe) deliveryId: number) {
    return this.deliveriesService.getDeliveryRiderLocation(deliveryId);
  }

  // Get delivery by ID
  @Get(':id')
  async getDelivery(@Param('id', ParseIntPipe) deliveryId: number) {
    return this.deliveriesService.getDeliveryById(deliveryId);
  }

  // Get all available deliveries (for riders)
  @Get('available')
  async getAvailableDeliveries() {
    return this.deliveriesService.getAvailableDeliveries();
  }
}

// Separate controller for user-specific delivery operations
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UserDeliveriesController {
  constructor(private readonly deliveriesService: DeliveriesService) {}

  // Get deliveries sent by a user
  @Get(':id/sent-deliveries')
  async getSentDeliveries(@Param('id', ParseIntPipe) userId: number) {
    return this.deliveriesService.getSentDeliveries(userId);
  }

  // Get deliveries received by a user
  @Get(':id/received-deliveries')
  async getReceivedDeliveries(@Param('id', ParseIntPipe) userId: number) {
    return this.deliveriesService.getReceivedDeliveries(userId);
  }
}
