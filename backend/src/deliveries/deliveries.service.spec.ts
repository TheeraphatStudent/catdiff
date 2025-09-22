import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DeliveriesService } from './deliveries.service';
import { Delivery, User, Address, Rider, RiderLocation } from '../entities';

describe('DeliveriesService', () => {
  let service: DeliveriesService;
  let deliveryRepository: Repository<Delivery>;
  let userRepository: Repository<User>;
  let addressRepository: Repository<Address>;
  let riderRepository: Repository<Rider>;
  let riderLocationRepository: Repository<RiderLocation>;

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

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DeliveriesService,
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

    service = module.get<DeliveriesService>(DeliveriesService);
    deliveryRepository = module.get<Repository<Delivery>>(getRepositoryToken(Delivery));
    userRepository = module.get<Repository<User>>(getRepositoryToken(User));
    addressRepository = module.get<Repository<Address>>(getRepositoryToken(Address));
    riderRepository = module.get<Repository<Rider>>(getRepositoryToken(Rider));
    riderLocationRepository = module.get<Repository<RiderLocation>>(getRepositoryToken(RiderLocation));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
