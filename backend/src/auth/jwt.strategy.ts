import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { AuthService } from './auth.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private authService: AuthService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'your_jwt_secret_here',
    });
  }

  async validate(payload: any) {
    if (payload.type === 'user') {
      const user = await this.authService.validateUser(payload.sub);
      if (user) {
        return { userId: payload.sub, phone_number: payload.phone_number, type: 'user' };
      }
    } else if (payload.type === 'rider') {
      const rider = await this.authService.validateRider(payload.sub);
      if (rider) {
        return { riderId: payload.sub, phone_number: payload.phone_number, type: 'rider' };
      }
    }
    return null;
  }
}
