import { Test, TestingModule } from '@nestjs/testing';
import { DeliveriesController, UserDeliveriesController } from '../src/deliveries/deliveries.controller';
import { DeliveriesService } from '../src/deliveries/deliveries.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Delivery, User, Address, Rider, RiderLocation, DeliveryStatus } from '../src/entities';

describe('DeliveriesController (Unit)', () => {
  let deliveriesController: DeliveriesController;
  let userDeliveriesController: UserDeliveriesController;
  let deliveriesService: DeliveriesService;

  const mockDeliveryRepository = {
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    find: jest.fn(),
  };

  const mockUserRepository = {
    findOne: jest.fn(),
  };

  const mockAddressRepository = {
    findOne: jest.fn(),
  };

  const mockRiderRepository = {
    findOne: jest.fn(),
  };

  const mockRiderLocationRepository = {
    findOne: jest.fn(),
  };

  const mockDeliveriesService = {
    createDelivery: jest.fn(),
    getDeliveryById: jest.fn(),
    getSentDeliveries: jest.fn(),
    getReceivedDeliveries: jest.fn(),
    getDeliveryRiderLocation: jest.fn(),
    getAvailableDeliveries: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [DeliveriesController, UserDeliveriesController],
      providers: [
        {
          provide: DeliveriesService,
          useValue: mockDeliveriesService,
        },
        {
          provide: getRepositoryToken(Delivery),
          useValue: mockDeliveryRepository,
        },
        {
          provide: getRepositoryToken(User),
          useValue: mockUserRepository,
        },
        {
          provide: getRepositoryToken(Address),
          useValue: mockAddressRepository,
        },
        {
          provide: getRepositoryToken(Rider),
          useValue: mockRiderRepository,
        },
        {
          provide: getRepositoryToken(RiderLocation),
          useValue: mockRiderLocationRepository,
        },
      ],
    }).compile();

    deliveriesController = module.get<DeliveriesController>(DeliveriesController);
    userDeliveriesController = module.get<UserDeliveriesController>(UserDeliveriesController);
    deliveriesService = module.get<DeliveriesService>(DeliveriesService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(deliveriesController).toBeDefined();
    expect(userDeliveriesController).toBeDefined();
  });

  describe('createDelivery', () => {
    it('should create a delivery successfully', async () => {
      const deliveryData = {
        sender_id: 1,
        receiver_id: 2,
        pickup_address_id: 1,
        delivery_address_id: 2,
        package_details: 'Electronics package',
      };

      const createdDelivery: Delivery = {
        delivery_id: 1,
        ...deliveryData,
        status: DeliveryStatus.WAITING,
        rider_id: null,
        pickup_image_url: null,
        in_transit_image_url: null,
        delivered_image_url: null,
        created_at: new Date(),
        updated_at: new Date(),
      } as any;

      mockDeliveriesService.createDelivery.mockResolvedValue(createdDelivery);

      const result = await deliveriesController.createDelivery(deliveryData);

      expect(mockDeliveriesService.createDelivery).toHaveBeenCalledWith(deliveryData);
      expect(result).toEqual(createdDelivery);
    });

    it('should handle delivery creation errors', async () => {
      const deliveryData = {
        sender_id: 1,
        receiver_id: 2,
        pickup_address_id: 1,
        delivery_address_id: 2,
        package_details: 'Electronics package',
      };

      const error = new Error('Failed to create delivery');
      mockDeliveriesService.createDelivery.mockRejectedValue(error);

      await expect(deliveriesController.createDelivery(deliveryData)).rejects.toThrow('Failed to create delivery');
    });
  });

  describe('getDelivery', () => {
    it('should return delivery by ID', async () => {
      const deliveryId = 1;
      const delivery: Delivery = {
        delivery_id: deliveryId,
        sender_id: 1,
        receiver_id: 2,
        pickup_address_id: 1,
        delivery_address_id: 2,
        status: DeliveryStatus.WAITING,
        package_details: 'Test package',
        rider_id: null,
        pickup_image_url: null,
        in_transit_image_url: null,
        delivered_image_url: null,
        created_at: new Date(),
        updated_at: new Date(),
      } as any;

      mockDeliveriesService.getDeliveryById.mockResolvedValue(delivery);

      const result = await deliveriesController.getDelivery(deliveryId);

      expect(mockDeliveriesService.getDeliveryById).toHaveBeenCalledWith(deliveryId);
      expect(result).toEqual(delivery);
    });
  });

  describe('getRiderLocation', () => {
    it('should return rider location for delivery', async () => {
      const deliveryId = 1;
      const riderLocation = {
        rider_id: 1,
        latitude: 13.7563,
        longitude: 100.5018,
        updated_at: new Date(),
      };

      mockDeliveriesService.getDeliveryRiderLocation.mockResolvedValue(riderLocation);

      const result = await deliveriesController.getRiderLocation(deliveryId);

      expect(mockDeliveriesService.getDeliveryRiderLocation).toHaveBeenCalledWith(deliveryId);
      expect(result).toEqual(riderLocation);
    });

    it('should return null when no rider assigned', async () => {
      const deliveryId = 1;

      mockDeliveriesService.getDeliveryRiderLocation.mockResolvedValue(null);

      const result = await deliveriesController.getRiderLocation(deliveryId);

      expect(result).toBeNull();
    });
  });

  describe('getSentDeliveries', () => {
    it('should return sent deliveries for user', async () => {
      const userId = 1;
      const deliveries: Delivery[] = [
        {
          delivery_id: 1,
          sender_id: userId,
          receiver_id: 2,
          pickup_address_id: 1,
          delivery_address_id: 2,
          status: DeliveryStatus.WAITING,
          package_details: 'Package 1',
          rider_id: null,
          created_at: new Date(),
          updated_at: new Date(),
        } as any,
        {
          delivery_id: 2,
          sender_id: userId,
          receiver_id: 3,
          pickup_address_id: 1,
          delivery_address_id: 3,
          status: DeliveryStatus.ACCEPTED,
          package_details: 'Package 2',
          rider_id: 1,
          created_at: new Date(),
          updated_at: new Date(),
        } as any,
      ];

      mockDeliveriesService.getSentDeliveries.mockResolvedValue(deliveries);

      const result = await userDeliveriesController.getSentDeliveries(userId);

      expect(mockDeliveriesService.getSentDeliveries).toHaveBeenCalledWith(userId);
      expect(result).toEqual(deliveries);
    });
  });

  describe('getReceivedDeliveries', () => {
    it('should return received deliveries for user', async () => {
      const userId = 2;
      const deliveries: Delivery[] = [
        {
          delivery_id: 1,
          sender_id: 1,
          receiver_id: userId,
          pickup_address_id: 1,
          delivery_address_id: 2,
          status: DeliveryStatus.WAITING,
          package_details: 'Received package',
          rider_id: null,
          created_at: new Date(),
          updated_at: new Date(),
        } as any,
      ];

      mockDeliveriesService.getReceivedDeliveries.mockResolvedValue(deliveries);

      const result = await userDeliveriesController.getReceivedDeliveries(userId);

      expect(mockDeliveriesService.getReceivedDeliveries).toHaveBeenCalledWith(userId);
      expect(result).toEqual(deliveries);
    });
  });

  describe('getAvailableDeliveries', () => {
    it('should return available deliveries', async () => {
      const deliveries: Delivery[] = [
        {
          delivery_id: 1,
          sender_id: 1,
          receiver_id: 2,
          pickup_address_id: 1,
          delivery_address_id: 2,
          status: DeliveryStatus.WAITING,
          package_details: 'Available package',
          rider_id: null,
          created_at: new Date(),
          updated_at: new Date(),
        } as any,
      ];

      mockDeliveriesService.getAvailableDeliveries.mockResolvedValue(deliveries);

      const result = await deliveriesController.getAvailableDeliveries();

      expect(mockDeliveriesService.getAvailableDeliveries).toHaveBeenCalled();
      expect(result).toEqual(deliveries);
    });
  });
});
