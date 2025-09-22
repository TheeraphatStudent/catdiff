import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RidersController } from './riders.controller';
import { RidersService } from './riders.service';
import { Rider, RiderLocation, Delivery } from '../entities';

describe('RidersController', () => {
  let controller: RidersController;
  let ridersService: RidersService;

  const mockRidersService = {
    updateRiderLocation: jest.fn(),
    getRiderLocation: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [RidersController],
      providers: [
        {
          provide: RidersService,
          useValue: mockRidersService,
        },
      ],
    }).compile();

    controller = module.get<RidersController>(RidersController);
    ridersService = module.get<RidersService>(RidersService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
