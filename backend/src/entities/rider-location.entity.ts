import { Entity, Column, PrimaryGeneratedColumn, UpdateDateColumn, OneToOne, JoinColumn } from 'typeorm';

@Entity('rider_locations')
export class RiderLocation {
  @PrimaryGeneratedColumn()
  rider_id: number;

  @Column({ type: 'decimal', precision: 10, scale: 7 })
  latitude: number;

  @Column({ type: 'decimal', precision: 10, scale: 7 })
  longitude: number;

  @UpdateDateColumn()
  updated_at: Date;

  @OneToOne('Rider', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'rider_id' })
  rider: any;
}
