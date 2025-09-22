import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RidersService } from './riders.service';
import { Rider, RiderLocation, Delivery, DeliveryStatus } from '../entities';

describe('RidersService', () => {
  let service: RidersService;
  let riderRepository: Repository<Rider>;
  let riderLocationRepository: Repository<RiderLocation>;
  let deliveryRepository: Repository<Delivery>;

  const mockRiderRepository = {
    findOne: jest.fn(),
  };

  const mockRiderLocationRepository = {
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
  };

  const mockDeliveryRepository = {
    findOne: jest.fn(),
    save: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RidersService,
        {
          provide: getRepositoryToken(Rider),
          useValue: mockRiderRepository,
        },
        {
          provide: getRepositoryToken(RiderLocation),
          useValue: mockRiderLocationRepository,
        },
        {
          provide: getRepositoryToken(Delivery),
          useValue: mockDeliveryRepository,
        },
      ],
    }).compile();

    service = module.get<RidersService>(RidersService);
    riderRepository = module.get<Repository<Rider>>(getRepositoryToken(Rider));
    riderLocationRepository = module.get<Repository<RiderLocation>>(getRepositoryToken(RiderLocation));
    deliveryRepository = module.get<Repository<Delivery>>(getRepositoryToken(Delivery));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('acceptDelivery', () => {
    it('should accept delivery successfully', async () => {
      const riderId = 1;
      const deliveryId = 1;

      const rider = { rider_id: riderId, name: 'Mike Rider' };
      const delivery = {
        delivery_id: deliveryId,
        status: DeliveryStatus.WAITING,
        rider_id: null,
      };
      const updatedDelivery = {
        ...delivery,
        status: DeliveryStatus.ACCEPTED,
        rider_id: riderId,
      };

      mockRiderRepository.findOne.mockResolvedValue(rider);
      mockDeliveryRepository.findOne.mockResolvedValue(delivery);
      mockDeliveryRepository.findOne
        .mockResolvedValueOnce(delivery) // First call for delivery check
        .mockResolvedValueOnce(null); // Second call for active delivery check
      mockDeliveryRepository.save.mockResolvedValue(updatedDelivery);

      const result = await service.acceptDelivery(riderId, deliveryId);

      expect(result).toEqual(updatedDelivery);
      expect(mockDeliveryRepository.save).toHaveBeenCalledWith({
        ...delivery,
        status: DeliveryStatus.ACCEPTED,
        rider_id: riderId,
      });
    });

    it('should throw error if delivery is not available', async () => {
      const riderId = 1;
      const deliveryId = 1;

      const rider = { rider_id: riderId, name: 'Mike Rider' };
      const delivery = {
        delivery_id: deliveryId,
        status: DeliveryStatus.ACCEPTED,
        rider_id: 2,
      };

      mockRiderRepository.findOne.mockResolvedValue(rider);
      mockDeliveryRepository.findOne.mockResolvedValue(delivery);

      await expect(service.acceptDelivery(riderId, deliveryId)).rejects.toThrow(
        'Delivery is not available for acceptance'
      );
    });

    it('should throw error if rider has active delivery', async () => {
      const riderId = 1;
      const deliveryId = 1;

      const rider = { rider_id: riderId, name: 'Mike Rider' };
      const delivery = {
        delivery_id: deliveryId,
        status: DeliveryStatus.WAITING,
        rider_id: null,
      };
      const activeDelivery = {
        delivery_id: 2,
        status: DeliveryStatus.ACCEPTED,
        rider_id: riderId,
      };

      mockRiderRepository.findOne.mockResolvedValue(rider);
      mockDeliveryRepository.findOne
        .mockResolvedValueOnce(delivery) // First call for delivery check
        .mockResolvedValueOnce(activeDelivery); // Second call for active delivery check

      await expect(service.acceptDelivery(riderId, deliveryId)).rejects.toThrow(
        'Rider can only accept one delivery at a time'
      );
    });
  });

  describe('updateDeliveryStatus', () => {
    it('should update delivery status successfully', async () => {
      const riderId = 1;
      const deliveryId = 1;
      const newStatus = DeliveryStatus.IN_TRANSIT;

      const rider = { rider_id: riderId, name: 'Mike Rider' };
      const delivery = {
        delivery_id: deliveryId,
        status: DeliveryStatus.ACCEPTED,
        rider_id: riderId,
        pickup_address: { latitude: 13.7563, longitude: 100.5018 },
        delivery_address: { latitude: 13.7564, longitude: 100.5019 },
      };
      const locationData = { latitude: 13.7563, longitude: 100.5018 }; // Within 20m of pickup

      const updatedDelivery = {
        ...delivery,
        status: newStatus,
        in_transit_image_url: 'pickup_image.jpg',
      };

      mockRiderRepository.findOne.mockResolvedValue(rider);
      mockDeliveryRepository.findOne.mockResolvedValue(delivery);
      mockDeliveryRepository.save.mockResolvedValue(updatedDelivery);

      const result = await service.updateDeliveryStatus(riderId, deliveryId, newStatus, locationData);

      expect(result).toEqual(updatedDelivery);
    });

    it('should throw error if rider is not assigned to delivery', async () => {
      const riderId = 1;
      const deliveryId = 1;
      const newStatus = DeliveryStatus.IN_TRANSIT;

      const rider = { rider_id: riderId, name: 'Mike Rider' };
      const delivery = {
        delivery_id: deliveryId,
        status: DeliveryStatus.ACCEPTED,
        rider_id: 2, // Different rider
      };

      mockRiderRepository.findOne.mockResolvedValue(rider);
      mockDeliveryRepository.findOne.mockResolvedValue(delivery);

      await expect(service.updateDeliveryStatus(riderId, deliveryId, newStatus)).rejects.toThrow(
        'Rider is not assigned to this delivery'
      );
    });

    it('should throw error for invalid status transition', async () => {
      const riderId = 1;
      const deliveryId = 1;
      const newStatus = DeliveryStatus.DELIVERED; // Invalid transition from WAITING

      const rider = { rider_id: riderId, name: 'Mike Rider' };
      const delivery = {
        delivery_id: deliveryId,
        status: DeliveryStatus.WAITING,
        rider_id: riderId,
      };

      mockRiderRepository.findOne.mockResolvedValue(rider);
      mockDeliveryRepository.findOne.mockResolvedValue(delivery);

      await expect(service.updateDeliveryStatus(riderId, deliveryId, newStatus)).rejects.toThrow(
        'Invalid status transition'
      );
    });

    it('should throw error if rider is too far from location', async () => {
      const riderId = 1;
      const deliveryId = 1;
      const newStatus = DeliveryStatus.IN_TRANSIT;

      const rider = { rider_id: riderId, name: 'Mike Rider' };
      const delivery = {
        delivery_id: deliveryId,
        status: DeliveryStatus.ACCEPTED,
        rider_id: riderId,
        pickup_address: { latitude: 13.7563, longitude: 100.5018 },
        delivery_address: { latitude: 13.7564, longitude: 100.5019 },
      };
      const locationData = { latitude: 13.8000, longitude: 100.6000 }; // Far from pickup location

      mockRiderRepository.findOne.mockResolvedValue(rider);
      mockDeliveryRepository.findOne.mockResolvedValue(delivery);

      await expect(service.updateDeliveryStatus(riderId, deliveryId, newStatus, locationData)).rejects.toThrow(
        'Rider must be within 20 meters of the target location'
      );
    });
  });

  describe('calculateDistance', () => {
    it('should calculate distance correctly', async () => {
      const riderId = 1;
      const deliveryId = 1;
      const newStatus = DeliveryStatus.IN_TRANSIT;

      const rider = { rider_id: riderId, name: 'Mike Rider' };
      const delivery = {
        delivery_id: deliveryId,
        status: DeliveryStatus.ACCEPTED,
        rider_id: riderId,
        pickup_address: { latitude: 13.7563, longitude: 100.5018 },
        delivery_address: { latitude: 13.7564, longitude: 100.5019 },
      };
      const locationData = { latitude: 13.7563, longitude: 100.5018 }; // Same as pickup location

      mockRiderRepository.findOne.mockResolvedValue(rider);
      mockDeliveryRepository.findOne.mockResolvedValue(delivery);
      mockDeliveryRepository.save.mockResolvedValue(delivery);

      await service.updateDeliveryStatus(riderId, deliveryId, newStatus, locationData);

      // Distance should be 0, so no error should be thrown
      expect(mockDeliveryRepository.save).toHaveBeenCalled();
    });
  });

  describe('updateRiderLocation', () => {
    it('should create new location if not exists', async () => {
      const riderId = 1;
      const locationData = { latitude: 13.7563, longitude: 100.5018 };

      const rider = { rider_id: riderId, name: 'Mike Rider' };
      const newLocation = {
        rider_id: riderId,
        latitude: locationData.latitude,
        longitude: locationData.longitude,
      };

      mockRiderRepository.findOne.mockResolvedValue(rider);
      mockRiderLocationRepository.findOne.mockResolvedValue(null);
      mockRiderLocationRepository.create.mockReturnValue(newLocation);
      mockRiderLocationRepository.save.mockResolvedValue(newLocation);

      const result = await service.updateRiderLocation(riderId, locationData);

      expect(result).toEqual(newLocation);
      expect(mockRiderLocationRepository.create).toHaveBeenCalledWith({
        rider_id: riderId,
        ...locationData,
      });
    });

    it('should update existing location', async () => {
      const riderId = 1;
      const locationData = { latitude: 13.7563, longitude: 100.5018 };

      const rider = { rider_id: riderId, name: 'Mike Rider' };
      const existingLocation = {
        rider_id: riderId,
        latitude: 13.7000,
        longitude: 100.4000,
        updated_at: new Date(),
      };

      const updatedLocation = {
        ...existingLocation,
        ...locationData,
      };

      mockRiderRepository.findOne.mockResolvedValue(rider);
      mockRiderLocationRepository.findOne.mockResolvedValue(existingLocation);
      mockRiderLocationRepository.save.mockResolvedValue(updatedLocation);

      const result = await service.updateRiderLocation(riderId, locationData);

      expect(result).toEqual(updatedLocation);
      expect(mockRiderLocationRepository.save).toHaveBeenCalledWith({
        ...existingLocation,
        ...locationData,
      });
    });
  });
});
