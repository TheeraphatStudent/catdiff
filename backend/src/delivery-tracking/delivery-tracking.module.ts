import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DeliveryTrackingGateway } from './delivery-tracking.gateway';
import { DeliveryTrackingService } from './delivery-tracking.service';
import { RiderLocation, Delivery, Rider } from '../entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([RiderLocation, Delivery, Rider]),
  ],
  providers: [DeliveryTrackingGateway, DeliveryTrackingService],
  exports: [DeliveryTrackingGateway, DeliveryTrackingService],
})
export class DeliveryTrackingModule {}
