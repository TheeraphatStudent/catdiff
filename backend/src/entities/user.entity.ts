import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';

export enum UserType {
  SENDER = 'sender',
  RECEIVER = 'receiver'
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('increment')
  user_id: number;

  @Column({ length: 20, unique: true })
  phone_number: string;

  @Column({ length: 255 })
  password_hash: string;

  @Column({ length: 100 })
  name: string;

  @Column({ length: 255, nullable: true })
  profile_image_url: string;

  @Column({
    type: 'enum',
    enum: UserType
  })
  user_type: UserType;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @OneToMany('Address', 'user')
  addresses: any[];

  @OneToMany('Delivery', 'sender')
  sent_deliveries: any[];

  @OneToMany('Delivery', 'receiver')
  received_deliveries: any[];
}
