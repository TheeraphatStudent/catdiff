import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DeliveriesService } from './deliveries.service';
import { DeliveriesController, UserDeliveriesController } from './deliveries.controller';
import { Delivery, User, Address, Rider, RiderLocation } from '../entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([Delivery, User, Address, Rider, RiderLocation]),
  ],
  providers: [DeliveriesService],
  controllers: [DeliveriesController, UserDeliveriesController],
  exports: [DeliveriesService],
})
export class DeliveriesModule {}
