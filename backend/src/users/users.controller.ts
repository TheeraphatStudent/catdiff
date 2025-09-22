import { Controller, Get, Post, Body, Param, ParseIntPipe, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // Get user's addresses
  @Get(':id/addresses')
  async getUserAddresses(@Param('id', ParseIntPipe) userId: number) {
    return this.usersService.getUserAddresses(userId);
  }

  // Add address for user
  @Post(':id/addresses')
  async addUserAddress(
    @Param('id', ParseIntPipe) userId: number,
    @Body() addressData: {
      address_line: string;
      latitude: number;
      longitude: number;
    }
  ) {
    return this.usersService.addUserAddress(userId, addressData);
  }
}
