import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { User, Address, Rider, Delivery, RiderLocation } from './entities';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { RidersModule } from './riders/riders.module';
import { DeliveriesModule } from './deliveries/deliveries.module';
import { DeliveryTrackingGateway } from './delivery-tracking/delivery-tracking.gateway';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DATABASE_HOST || 'localhost',
      port: parseInt(process.env.DATABASE_PORT || '5432'),
      username: process.env.DATABASE_USERNAME || 'catdiff_user',
      password: process.env.DATABASE_PASSWORD || 'catdiff_password',
      database: process.env.DATABASE_NAME || 'catdiff_delivery',
      entities: [User, Address, Rider, Delivery, RiderLocation],
      synchronize: process.env.NODE_ENV !== 'production', // Don't use in production
      logging: process.env.NODE_ENV === 'development',
    }),
    TypeOrmModule.forFeature([User, Address, Rider, Delivery, RiderLocation]),
    AuthModule,
    UsersModule,
    RidersModule,
    DeliveriesModule,
  ],
  controllers: [AppController],
  providers: [AppService, DeliveryTrackingGateway],
})
export class AppModule {}
