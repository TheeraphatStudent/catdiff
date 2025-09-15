import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { AuthService } from './auth.service';
import { User, Rider, UserType } from '../entities';

describe('AuthService', () => {
  let service: AuthService;
  let userRepository: Repository<User>;
  let riderRepository: Repository<Rider>;
  let jwtService: JwtService;

  const mockUserRepository = {
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
  };

  const mockRiderRepository = {
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
  };

  const mockJwtService = {
    sign: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: getRepositoryToken(User),
          useValue: mockUserRepository,
        },
        {
          provide: getRepositoryToken(Rider),
          useValue: mockRiderRepository,
        },
        {
          provide: JwtService,
          useValue: mockJwtService,
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    userRepository = module.get<Repository<User>>(getRepositoryToken(User));
    riderRepository = module.get<Repository<Rider>>(getRepositoryToken(Rider));
    jwtService = module.get<JwtService>(JwtService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('registerUser', () => {
    it('should register a new user successfully', async () => {
      const userData = {
        phone_number: '0812345678',
        password: 'password123',
        name: 'John Doe',
        user_type: 'sender',
      };

      const hashedPassword = 'hashedPassword';
      const savedUser = {
        user_id: 1,
        ...userData,
        password_hash: hashedPassword,
        user_type: UserType.SENDER,
        created_at: new Date(),
        updated_at: new Date(),
      };

      const token = 'jwt_token';

      mockUserRepository.findOne.mockResolvedValue(null);
      jest.spyOn(bcrypt, 'hash').mockResolvedValue(hashedPassword);
      mockUserRepository.create.mockReturnValue(savedUser);
      mockUserRepository.save.mockResolvedValue(savedUser);
      mockJwtService.sign.mockReturnValue(token);

      const result = await service.registerUser(userData);

      expect(mockUserRepository.findOne).toHaveBeenCalledWith({
        where: { phone_number: userData.phone_number }
      });
      expect(bcrypt.hash).toHaveBeenCalledWith(userData.password, 10);
      expect(mockUserRepository.create).toHaveBeenCalledWith({
        phone_number: userData.phone_number,
        password_hash: hashedPassword,
        name: userData.name,
        user_type: UserType.SENDER,
      });
      expect(mockJwtService.sign).toHaveBeenCalledWith({
        sub: savedUser.user_id,
        phone_number: savedUser.phone_number,
        type: 'user',
      });
      expect(result).toEqual({
        access_token: token,
        user: {
          user_id: savedUser.user_id,
          phone_number: savedUser.phone_number,
          name: savedUser.name,
          user_type: savedUser.user_type,
        },
      });
    });

    it('should throw ConflictException if user already exists', async () => {
      const userData = {
        phone_number: '0812345678',
        password: 'password123',
        name: 'John Doe',
        user_type: 'sender',
      };

      mockUserRepository.findOne.mockResolvedValue({
        user_id: 1,
        phone_number: userData.phone_number,
      });

      await expect(service.registerUser(userData)).rejects.toThrow(
        'User with this phone number already exists'
      );
    });
  });

  describe('loginUser', () => {
    it('should login user successfully', async () => {
      const credentials = {
        phone_number: '0812345678',
        password: 'password123',
      };

      const user = {
        user_id: 1,
        phone_number: credentials.phone_number,
        password_hash: 'hashedPassword',
        name: 'John Doe',
        user_type: UserType.SENDER,
      };

      const token = 'jwt_token';

      mockUserRepository.findOne.mockResolvedValue(user);
      jest.spyOn(bcrypt, 'compare').mockResolvedValue(true);
      mockJwtService.sign.mockReturnValue(token);

      const result = await service.loginUser(credentials);

      expect(mockUserRepository.findOne).toHaveBeenCalledWith({
        where: { phone_number: credentials.phone_number }
      });
      expect(bcrypt.compare).toHaveBeenCalledWith(credentials.password, user.password_hash);
      expect(result).toEqual({
        access_token: token,
        user: {
          user_id: user.user_id,
          phone_number: user.phone_number,
          name: user.name,
          user_type: user.user_type,
        },
      });
    });

    it('should throw UnauthorizedException if user not found', async () => {
      const credentials = {
        phone_number: '0812345678',
        password: 'password123',
      };

      mockUserRepository.findOne.mockResolvedValue(null);

      await expect(service.loginUser(credentials)).rejects.toThrow(
        'Invalid credentials'
      );
    });

    it('should throw UnauthorizedException if password is invalid', async () => {
      const credentials = {
        phone_number: '0812345678',
        password: 'password123',
      };

      const user = {
        user_id: 1,
        phone_number: credentials.phone_number,
        password_hash: 'hashedPassword',
        name: 'John Doe',
        user_type: UserType.SENDER,
      };

      mockUserRepository.findOne.mockResolvedValue(user);
      jest.spyOn(bcrypt, 'compare').mockResolvedValue(false);

      await expect(service.loginUser(credentials)).rejects.toThrow(
        'Invalid credentials'
      );
    });
  });

  describe('registerRider', () => {
    it('should register a new rider successfully', async () => {
      const riderData = {
        phone_number: '0912345678',
        password: 'password123',
        name: 'Mike Rider',
        vehicle_plate: 'ABC-123',
      };

      const hashedPassword = 'hashedPassword';
      const savedRider = {
        rider_id: 1,
        ...riderData,
        password_hash: hashedPassword,
        created_at: new Date(),
        updated_at: new Date(),
      };

      const token = 'jwt_token';

      mockRiderRepository.findOne.mockResolvedValue(null);
      jest.spyOn(bcrypt, 'hash').mockResolvedValue(hashedPassword);
      mockRiderRepository.create.mockReturnValue(savedRider);
      mockRiderRepository.save.mockResolvedValue(savedRider);
      mockJwtService.sign.mockReturnValue(token);

      const result = await service.registerRider(riderData);

      expect(mockRiderRepository.findOne).toHaveBeenCalledWith({
        where: { phone_number: riderData.phone_number }
      });
      expect(mockRiderRepository.findOne).toHaveBeenCalledWith({
        where: { vehicle_plate: riderData.vehicle_plate }
      });
      expect(result).toEqual({
        access_token: token,
        rider: {
          rider_id: savedRider.rider_id,
          phone_number: savedRider.phone_number,
          name: savedRider.name,
          vehicle_plate: savedRider.vehicle_plate,
        },
      });
    });

    it('should throw ConflictException if rider already exists', async () => {
      const riderData = {
        phone_number: '0912345678',
        password: 'password123',
        name: 'Mike Rider',
        vehicle_plate: 'ABC-123',
      };

      mockRiderRepository.findOne.mockResolvedValue({
        rider_id: 1,
        phone_number: riderData.phone_number,
      });

      await expect(service.registerRider(riderData)).rejects.toThrow(
        'Rider with this phone number already exists'
      );
    });

    it('should throw ConflictException if vehicle plate already registered', async () => {
      const riderData = {
        phone_number: '0912345678',
        password: 'password123',
        name: 'Mike Rider',
        vehicle_plate: 'ABC-123',
      };

      mockRiderRepository.findOne
        .mockResolvedValueOnce(null) // Phone number check
        .mockResolvedValueOnce({ rider_id: 2, vehicle_plate: riderData.vehicle_plate }); // Vehicle plate check

      await expect(service.registerRider(riderData)).rejects.toThrow(
        'Vehicle plate already registered'
      );
    });
  });

  describe('loginRider', () => {
    it('should login rider successfully', async () => {
      const credentials = {
        phone_number: '0912345678',
        password: 'password123',
      };

      const rider = {
        rider_id: 1,
        phone_number: credentials.phone_number,
        password_hash: 'hashedPassword',
        name: 'Mike Rider',
        vehicle_plate: 'ABC-123',
      };

      const token = 'jwt_token';

      mockRiderRepository.findOne.mockResolvedValue(rider);
      jest.spyOn(bcrypt, 'compare').mockResolvedValue(true);
      mockJwtService.sign.mockReturnValue(token);

      const result = await service.loginRider(credentials);

      expect(result).toEqual({
        access_token: token,
        rider: {
          rider_id: rider.rider_id,
          phone_number: rider.phone_number,
          name: rider.name,
          vehicle_plate: rider.vehicle_plate,
        },
      });
    });
  });

  describe('validateUser', () => {
    it('should return user if found', async () => {
      const user = { user_id: 1, name: 'John Doe' };
      mockUserRepository.findOne.mockResolvedValue(user);

      const result = await service.validateUser(1);

      expect(result).toEqual(user);
    });

    it('should return null if user not found', async () => {
      mockUserRepository.findOne.mockResolvedValue(null);

      const result = await service.validateUser(1);

      expect(result).toBeNull();
    });
  });

  describe('validateRider', () => {
    it('should return rider if found', async () => {
      const rider = { rider_id: 1, name: 'Mike Rider' };
      mockRiderRepository.findOne.mockResolvedValue(rider);

      const result = await service.validateRider(1);

      expect(result).toEqual(rider);
    });

    it('should return null if rider not found', async () => {
      mockRiderRepository.findOne.mockResolvedValue(null);

      const result = await service.validateRider(1);

      expect(result).toBeNull();
    });
  });
});
