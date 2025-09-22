import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, OneToMany, OneToOne, JoinColumn } from 'typeorm';

@Entity('riders')
export class Rider {
  @PrimaryGeneratedColumn('increment')
  rider_id: number;

  @Column({ length: 20, unique: true })
  phone_number: string;

  @Column({ length: 255 })
  password_hash: string;

  @Column({ length: 100 })
  name: string;

  @Column({ length: 255, nullable: true })
  profile_image_url: string;

  @Column({ length: 255, nullable: true })
  vehicle_image_url: string;

  @Column({ length: 20, unique: true })
  vehicle_plate: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @OneToMany('Delivery', 'rider')
  deliveries: any[];

  @OneToOne('RiderLocation', { cascade: true })
  @JoinColumn({ name: 'rider_id' })
  location: any;
}
