import { Injectable, ConflictException, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { User, Rider } from '../entities';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Rider)
    private riderRepository: Repository<Rider>,
    private jwtService: JwtService,
  ) {}

  // User registration
  async registerUser(userData: {
    phone_number: string;
    password: string;
    name: string;
    user_type: string;
  }) {
    const { phone_number, password, name, user_type } = userData;

    // Check if user already exists
    const existingUser = await this.userRepository.findOne({ where: { phone_number } });
    if (existingUser) {
      throw new ConflictException('User with this phone number already exists');
    }

    // Hash password
    const saltRounds = 10;
    const password_hash = await bcrypt.hash(password, saltRounds);

    // Create user
    const user = this.userRepository.create({
      phone_number,
      password_hash,
      name,
      user_type: user_type as any,
    });

    await this.userRepository.save(user);

    // Generate JWT token
    const payload = { sub: user.user_id, phone_number: user.phone_number, type: 'user' };
    const access_token = this.jwtService.sign(payload);

    return {
      access_token,
      user: {
        user_id: user.user_id,
        phone_number: user.phone_number,
        name: user.name,
        user_type: user.user_type,
      },
    };
  }

  // User login
  async loginUser(credentials: { phone_number: string; password: string }) {
    const { phone_number, password } = credentials;

    const user = await this.userRepository.findOne({ where: { phone_number } });
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = { sub: user.user_id, phone_number: user.phone_number, type: 'user' };
    const access_token = this.jwtService.sign(payload);

    return {
      access_token,
      user: {
        user_id: user.user_id,
        phone_number: user.phone_number,
        name: user.name,
        user_type: user.user_type,
      },
    };
  }

  // Rider registration
  async registerRider(riderData: {
    phone_number: string;
    password: string;
    name: string;
    vehicle_plate: string;
  }) {
    const { phone_number, password, name, vehicle_plate } = riderData;

    // Check if rider already exists
    const existingRider = await this.riderRepository.findOne({ where: { phone_number } });
    if (existingRider) {
      throw new ConflictException('Rider with this phone number already exists');
    }

    // Check if vehicle plate is already registered
    const existingPlate = await this.riderRepository.findOne({ where: { vehicle_plate } });
    if (existingPlate) {
      throw new ConflictException('Vehicle plate already registered');
    }

    // Hash password
    const saltRounds = 10;
    const password_hash = await bcrypt.hash(password, saltRounds);

    // Create rider
    const rider = this.riderRepository.create({
      phone_number,
      password_hash,
      name,
      vehicle_plate,
    });

    await this.riderRepository.save(rider);

    // Generate JWT token
    const payload = { sub: rider.rider_id, phone_number: rider.phone_number, type: 'rider' };
    const access_token = this.jwtService.sign(payload);

    return {
      access_token,
      rider: {
        rider_id: rider.rider_id,
        phone_number: rider.phone_number,
        name: rider.name,
        vehicle_plate: rider.vehicle_plate,
      },
    };
  }

  // Rider login
  async loginRider(credentials: { phone_number: string; password: string }) {
    const { phone_number, password } = credentials;

    const rider = await this.riderRepository.findOne({ where: { phone_number } });
    if (!rider) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(password, rider.password_hash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = { sub: rider.rider_id, phone_number: rider.phone_number, type: 'rider' };
    const access_token = this.jwtService.sign(payload);

    return {
      access_token,
      rider: {
        rider_id: rider.rider_id,
        phone_number: rider.phone_number,
        name: rider.name,
        vehicle_plate: rider.vehicle_plate,
      },
    };
  }

  // Validate user by ID
  async validateUser(userId: number): Promise<User | null> {
    return this.userRepository.findOne({ where: { user_id: userId } });
  }

  // Validate rider by ID
  async validateRider(riderId: number): Promise<Rider | null> {
    return this.riderRepository.findOne({ where: { rider_id: riderId } });
  }
}
