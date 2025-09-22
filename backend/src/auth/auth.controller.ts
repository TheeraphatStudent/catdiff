import { Controller, Post, Body } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // User registration
  @Post('users/register')
  async registerUser(@Body() userData: {
    phone_number: string;
    password: string;
    name: string;
    user_type: string;
  }) {
    return this.authService.registerUser(userData);
  }

  // User login
  @Post('users/login')
  async loginUser(@Body() credentials: { phone_number: string; password: string }) {
    return this.authService.loginUser(credentials);
  }

  // Rider registration
  @Post('riders/register')
  async registerRider(@Body() riderData: {
    phone_number: string;
    password: string;
    name: string;
    vehicle_plate: string;
  }) {
    return this.authService.registerRider(riderData);
  }

  // Rider login
  @Post('riders/login')
  async loginRider(@Body() credentials: { phone_number: string; password: string }) {
    return this.authService.loginRider(credentials);
  }
}
