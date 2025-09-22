import { Test, TestingModule } from '@nestjs/testing';
import { UsersController } from '../src/users/users.controller';
import { UsersService } from '../src/users/users.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, Address } from '../src/entities';

describe('UsersController (Unit)', () => {
  let controller: UsersController;
  let usersService: UsersService;

  const mockUserRepository = {
    findOne: jest.fn(),
  };

  const mockAddressRepository = {
    find: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
  };

  const mockUsersService = {
    getUserAddresses: jest.fn(),
    addUserAddress: jest.fn(),
    findUserById: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [
        {
          provide: UsersService,
          useValue: mockUsersService,
        },
        {
          provide: getRepositoryToken(User),
          useValue: mockUserRepository,
        },
        {
          provide: getRepositoryToken(Address),
          useValue: mockAddressRepository,
        },
      ],
    }).compile();

    controller = module.get<UsersController>(UsersController);
    usersService = module.get<UsersService>(UsersService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getUserAddresses', () => {
    it('should return user addresses successfully', async () => {
      const userId = 1;
      const addresses = [
        {
          address_id: 1,
          user_id: userId,
          address_line: '123 Main St, Bangkok',
          latitude: 13.7563,
          longitude: 100.5018,
          created_at: new Date(),
          updated_at: new Date(),
        },
        {
          address_id: 2,
          user_id: userId,
          address_line: '456 Oak Ave, Bangkok',
          latitude: 13.7564,
          longitude: 100.5019,
          created_at: new Date(),
          updated_at: new Date(),
        },
      ];

      mockUsersService.getUserAddresses.mockResolvedValue(addresses);

      const result = await controller.getUserAddresses(userId);

      expect(mockUsersService.getUserAddresses).toHaveBeenCalledWith(userId);
      expect(result).toEqual(addresses);
    });

    it('should handle errors when getting user addresses', async () => {
      const userId = 1;
      const error = new Error('Failed to get addresses');
      mockUsersService.getUserAddresses.mockRejectedValue(error);

      await expect(controller.getUserAddresses(userId)).rejects.toThrow('Failed to get addresses');
    });
  });

  describe('addUserAddress', () => {
    it('should add user address successfully', async () => {
      const userId = 1;
      const addressData = {
        address_line: '789 Pine Rd, Bangkok',
        latitude: 13.7565,
        longitude: 100.5020,
      };

      const newAddress = {
        address_id: 3,
        user_id: userId,
        ...addressData,
        created_at: new Date(),
        updated_at: new Date(),
      };

      mockUsersService.addUserAddress.mockResolvedValue(newAddress);

      const result = await controller.addUserAddress(userId, addressData);

      expect(mockUsersService.addUserAddress).toHaveBeenCalledWith(userId, addressData);
      expect(result).toEqual(newAddress);
    });

    it('should handle errors when adding user address', async () => {
      const userId = 1;
      const addressData = {
        address_line: '789 Pine Rd, Bangkok',
        latitude: 13.7565,
        longitude: 100.5020,
      };

      const error = new Error('Failed to add address');
      mockUsersService.addUserAddress.mockRejectedValue(error);

      await expect(controller.addUserAddress(userId, addressData)).rejects.toThrow('Failed to add address');
    });
  });
});
