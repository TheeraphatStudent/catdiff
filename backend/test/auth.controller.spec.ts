import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from '../src/auth/auth.controller';
import { AuthService } from '../src/auth/auth.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import { User, Rider, UserType } from '../src/entities';

describe('AuthController (Unit)', () => {
  let controller: AuthController;
  let authService: AuthService;

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

  const mockAuthService = {
    registerUser: jest.fn(),
    loginUser: jest.fn(),
    registerRider: jest.fn(),
    loginRider: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        {
          provide: AuthService,
          useValue: mockAuthService,
        },
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

    controller = module.get<AuthController>(AuthController);
    authService = module.get<AuthService>(AuthService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('registerUser', () => {
    it('should register a user successfully', async () => {
      const userData = {
        phone_number: '0812345678',
        password: 'password123',
        name: 'John Doe',
        user_type: 'sender',
      };

      const expectedResult = {
        access_token: 'jwt_token',
        user: {
          user_id: 1,
          phone_number: '0812345678',
          name: 'John Doe',
          user_type: UserType.SENDER,
        },
      };

      mockAuthService.registerUser.mockResolvedValue(expectedResult);

      const result = await controller.registerUser(userData);

      expect(mockAuthService.registerUser).toHaveBeenCalledWith(userData);
      expect(result).toEqual(expectedResult);
    });

    it('should handle registration errors', async () => {
      const userData = {
        phone_number: '0812345678',
        password: 'password123',
        name: 'John Doe',
        user_type: 'sender',
      };

      const error = new Error('Registration failed');
      mockAuthService.registerUser.mockRejectedValue(error);

      await expect(controller.registerUser(userData)).rejects.toThrow('Registration failed');
    });
  });

  describe('loginUser', () => {
    it('should login a user successfully', async () => {
      const credentials = {
        phone_number: '0812345678',
        password: 'password123',
      };

      const expectedResult = {
        access_token: 'jwt_token',
        user: {
          user_id: 1,
          phone_number: '0812345678',
          name: 'John Doe',
          user_type: UserType.SENDER,
        },
      };

      mockAuthService.loginUser.mockResolvedValue(expectedResult);

      const result = await controller.loginUser(credentials);

      expect(mockAuthService.loginUser).toHaveBeenCalledWith(credentials);
      expect(result).toEqual(expectedResult);
    });

    it('should handle login errors', async () => {
      const credentials = {
        phone_number: '0812345678',
        password: 'password123',
      };

      const error = new Error('Login failed');
      mockAuthService.loginUser.mockRejectedValue(error);

      await expect(controller.loginUser(credentials)).rejects.toThrow('Login failed');
    });
  });

  describe('registerRider', () => {
    it('should register a rider successfully', async () => {
      const riderData = {
        phone_number: '0912345678',
        password: 'password123',
        name: 'Mike Rider',
        vehicle_plate: 'ABC-123',
      };

      const expectedResult = {
        access_token: 'jwt_token',
        rider: {
          rider_id: 1,
          phone_number: '0912345678',
          name: 'Mike Rider',
          vehicle_plate: 'ABC-123',
        },
      };

      mockAuthService.registerRider.mockResolvedValue(expectedResult);

      const result = await controller.registerRider(riderData);

      expect(mockAuthService.registerRider).toHaveBeenCalledWith(riderData);
      expect(result).toEqual(expectedResult);
    });

    it('should handle rider registration errors', async () => {
      const riderData = {
        phone_number: '0912345678',
        password: 'password123',
        name: 'Mike Rider',
        vehicle_plate: 'ABC-123',
      };

      const error = new Error('Rider registration failed');
      mockAuthService.registerRider.mockRejectedValue(error);

      await expect(controller.registerRider(riderData)).rejects.toThrow('Rider registration failed');
    });
  });

  describe('loginRider', () => {
    it('should login a rider successfully', async () => {
      const credentials = {
        phone_number: '0912345678',
        password: 'password123',
      };

      const expectedResult = {
        access_token: 'jwt_token',
        rider: {
          rider_id: 1,
          phone_number: '0912345678',
          name: 'Mike Rider',
          vehicle_plate: 'ABC-123',
        },
      };

      mockAuthService.loginRider.mockResolvedValue(expectedResult);

      const result = await controller.loginRider(credentials);

      expect(mockAuthService.loginRider).toHaveBeenCalledWith(credentials);
      expect(result).toEqual(expectedResult);
    });

    it('should handle rider login errors', async () => {
      const credentials = {
        phone_number: '0912345678',
        password: 'password123',
      };

      const error = new Error('Rider login failed');
      mockAuthService.loginRider.mockRejectedValue(error);

      await expect(controller.loginRider(credentials)).rejects.toThrow('Rider login failed');
    });
  });
});
