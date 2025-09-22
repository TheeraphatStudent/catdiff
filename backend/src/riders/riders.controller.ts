import { Controller, Get, Patch, Param, Body, ParseIntPipe, UseGuards } from '@nestjs/common';
import { RidersService } from './riders.service';
import { DeliveryStatus } from '../entities';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('riders')
@UseGuards(JwtAuthGuard)
export class RidersController {
  constructor(private readonly ridersService: RidersService) {}

  // Update rider location
  @Patch(':id/location')
  async updateLocation(
    @Param('id', ParseIntPipe) riderId: number,
    @Body() locationData: { latitude: number; longitude: number }
  ) {
    return this.ridersService.updateRiderLocation(riderId, locationData);
  }

  // Get rider location
  @Get(':id/location')
  async getLocation(@Param('id', ParseIntPipe) riderId: number) {
    return this.ridersService.getRiderLocation(riderId);
  }
}

// Separate controller for delivery operations
@Controller('deliveries')
@UseGuards(JwtAuthGuard)
export class DeliveryRiderController {
  constructor(private readonly ridersService: RidersService) {}

  // Accept delivery
  @Patch(':id/accept')
  async acceptDelivery(
    @Param('id', ParseIntPipe) deliveryId: number,
    @Body() body: { rider_id: number }
  ) {
    const { rider_id } = body;
    return this.ridersService.acceptDelivery(rider_id, deliveryId);
  }

  // Update delivery status
  @Patch(':id/status')
  async updateStatus(
    @Param('id', ParseIntPipe) deliveryId: number,
    @Body() statusData: {
      rider_id: number;
      status: DeliveryStatus;
      latitude?: number;
      longitude?: number;
    }
  ) {
    const { rider_id, status, latitude, longitude } = statusData;
    const locationData = latitude && longitude ? { latitude, longitude } : undefined;
    return this.ridersService.updateDeliveryStatus(rider_id, deliveryId, status, locationData);
  }
}
