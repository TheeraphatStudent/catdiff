import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, Address } from '../entities';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Address)
    private addressRepository: Repository<Address>,
  ) {}

  // Get user by ID
  async findUserById(userId: number): Promise<User> {
    const user = await this.userRepository.findOne({ where: { user_id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  // Get user's addresses
  async getUserAddresses(userId: number): Promise<Address[]> {
    await this.findUserById(userId); // Verify user exists

    return this.addressRepository.find({
      where: { user_id: userId },
      order: { created_at: 'DESC' },
    });
  }

  // Add address for user
  async addUserAddress(
    userId: number,
    addressData: {
      address_line: string;
      latitude: number;
      longitude: number;
    }
  ): Promise<Address> {
    await this.findUserById(userId); // Verify user exists

    const address = this.addressRepository.create({
      user_id: userId,
      ...addressData,
    });

    return this.addressRepository.save(address);
  }
}
