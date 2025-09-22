import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { DeliveryTrackingService } from './delivery-tracking.service';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
  namespace: '/delivery-tracking',
})
export class DeliveryTrackingGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private logger: Logger = new Logger('DeliveryTrackingGateway');

  constructor(private readonly deliveryTrackingService: DeliveryTrackingService) {}

  handleConnection(client: Socket, ...args: any[]) {
    this.logger.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
    // Clean up subscriptions when client disconnects
    this.deliveryTrackingService.removeClientSubscriptions(client.id);
  }

  // Subscribe to delivery tracking
  @SubscribeMessage('subscribe-delivery')
  handleSubscribeDelivery(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { deliveryId: number; userId: number; userType: 'sender' | 'receiver' }
  ) {
    const { deliveryId, userId, userType } = data;
    this.logger.log(`Client ${client.id} subscribing to delivery ${deliveryId} as ${userType}`);

    // Add client to delivery room
    client.join(`delivery-${deliveryId}`);

    // Store subscription for cleanup
    this.deliveryTrackingService.addClientSubscription(client.id, deliveryId, userId, userType);

    // Send current delivery status and rider location if available
    this.deliveryTrackingService.sendCurrentDeliveryState(client, deliveryId);

    return { event: 'subscribed', data: { deliveryId, status: 'success' } };
  }

  // Unsubscribe from delivery tracking
  @SubscribeMessage('unsubscribe-delivery')
  handleUnsubscribeDelivery(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { deliveryId: number }
  ) {
    const { deliveryId } = data;
    this.logger.log(`Client ${client.id} unsubscribing from delivery ${deliveryId}`);

    // Remove client from delivery room
    client.leave(`delivery-${deliveryId}`);

    // Remove subscription
    this.deliveryTrackingService.removeClientSubscription(client.id, deliveryId);

    return { event: 'unsubscribed', data: { deliveryId, status: 'success' } };
  }

  // Rider location update (sent by rider app)
  @SubscribeMessage('rider-location-update')
  handleRiderLocationUpdate(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: {
      deliveryId: number;
      riderId: number;
      latitude: number;
      longitude: number;
    }
  ) {
    const { deliveryId, riderId, latitude, longitude } = data;
    this.logger.log(`Rider ${riderId} location update for delivery ${deliveryId}: ${latitude}, ${longitude}`);

    // Update rider location in database
    this.deliveryTrackingService.updateRiderLocation(riderId, latitude, longitude);

    // Broadcast location update to all clients subscribed to this delivery
    this.server.to(`delivery-${deliveryId}`).emit('rider-location-update', {
      deliveryId,
      riderId,
      latitude,
      longitude,
      timestamp: new Date().toISOString(),
    });

    return { event: 'location-updated', data: { deliveryId, status: 'success' } };
  }

  // Delivery status update (sent by rider app)
  @SubscribeMessage('delivery-status-update')
  handleDeliveryStatusUpdate(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: {
      deliveryId: number;
      riderId: number;
      status: string;
      imageUrl?: string;
    }
  ) {
    const { deliveryId, riderId, status, imageUrl } = data;
    this.logger.log(`Delivery ${deliveryId} status update to ${status} by rider ${riderId}`);

    // Update delivery status in database
    this.deliveryTrackingService.updateDeliveryStatus(deliveryId, riderId, status, imageUrl);

    // Broadcast status update to all clients subscribed to this delivery
    this.server.to(`delivery-${deliveryId}`).emit('delivery-status-update', {
      deliveryId,
      riderId,
      status,
      imageUrl,
      timestamp: new Date().toISOString(),
    });

    return { event: 'status-updated', data: { deliveryId, status: 'success' } };
  }

  // Get current delivery state (for newly connected clients)
  @SubscribeMessage('get-delivery-state')
  handleGetDeliveryState(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { deliveryId: number }
  ) {
    const { deliveryId } = data;
    this.logger.log(`Client ${client.id} requesting delivery state for ${deliveryId}`);

    return this.deliveryTrackingService.sendCurrentDeliveryState(client, deliveryId);
  }
}
