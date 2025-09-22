import { Test, TestingModule } from '@nestjs/testing';
import { DeliveryTrackingGateway } from './delivery-tracking.gateway';

describe('DeliveryTrackingGateway', () => {
  let gateway: DeliveryTrackingGateway;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [DeliveryTrackingGateway],
    }).compile();

    gateway = module.get<DeliveryTrackingGateway>(DeliveryTrackingGateway);
  });

  it('should be defined', () => {
    expect(gateway).toBeDefined();
  });
});
