import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';

export enum DeliveryStatus {
  WAITING = 'waiting',
  ACCEPTED = 'accepted',
  IN_TRANSIT = 'in_transit',
  DELIVERED = 'delivered'
}

@Entity('deliveries')
export class Delivery {
  @PrimaryGeneratedColumn('increment')
  delivery_id: number;

  @Column()
  sender_id: number;

  @Column()
  receiver_id: number;

  @Column()
  pickup_address_id: number;

  @Column()
  delivery_address_id: number;

  @Column({
    type: 'enum',
    enum: DeliveryStatus,
    default: DeliveryStatus.WAITING
  })
  status: DeliveryStatus;

  @Column({ type: 'text', nullable: true })
  package_details: string;

  @Column({ length: 255, nullable: true })
  pickup_image_url: string;

  @Column({ length: 255, nullable: true })
  in_transit_image_url: string;

  @Column({ length: 255, nullable: true })
  delivered_image_url: string;

  @Column({ nullable: true })
  rider_id: number;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @ManyToOne('User', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'sender_id' })
  sender: any;

  @ManyToOne('User', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'receiver_id' })
  receiver: any;

  @ManyToOne('Address', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'pickup_address_id' })
  pickup_address: any;

  @ManyToOne('Address', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'delivery_address_id' })
  delivery_address: any;

  @ManyToOne('Rider', { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'rider_id' })
  rider: any;
}
