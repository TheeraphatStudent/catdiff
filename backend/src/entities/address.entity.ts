import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn, OneToMany } from 'typeorm';

@Entity('addresses')
export class Address {
  @PrimaryGeneratedColumn('increment')
  address_id: number;

  @Column()
  user_id: number;

  @Column({ length: 255 })
  address_line: string;

  @Column({ type: 'decimal', precision: 10, scale: 7 })
  latitude: number;

  @Column({ type: 'decimal', precision: 10, scale: 7 })
  longitude: number;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @ManyToOne('User', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: any;

  @OneToMany('Delivery', 'pickup_address')
  pickup_deliveries: any[];

  @OneToMany('Delivery', 'delivery_address')
  delivery_deliveries: any[];
}
