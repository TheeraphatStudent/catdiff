import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RidersService } from './riders.service';
import { RidersController, DeliveryRiderController } from './riders.controller';
import { Rider, RiderLocation, Delivery } from '../entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([Rider, RiderLocation, Delivery]),
  ],
  providers: [RidersService],
  controllers: [RidersController, DeliveryRiderController],
  exports: [RidersService],
})
export class RidersModule {}
