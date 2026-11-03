import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { AccountsModule } from './accounts/accounts.module';
import { VetRequestsModule } from './vet-requests/vet-requests.module';
import { UserAdminModule } from './user-admin/user-admin.module';
import { AccessControlModule } from './access-control/access-control.module';
import { PetsModule } from './pets/pets.module';
import { PetTypesModule } from './pet-types/pet-types.module';
import { HistoryModule } from './history/history.module';
import { CarnetVetsModule } from './carnet-vets/carnet-vets.module';
import { VetConsultModule } from './vet-consult/vet-consult.module';
import { AdminMetricsModule } from './admin-metrics/admin-metrics.module';
import { AuditMetricsModule } from './audit-metrics/audit-metrics.module';
import { ActionLogModule } from './action-log/action-log.module';
import { MailModule } from './mail/mail.module';

@Module({
  imports: [
    AuthModule,
    AccountsModule,
    VetRequestsModule,
    UserAdminModule,
    AccessControlModule,
    PetsModule,
    PetTypesModule,
    HistoryModule,
    CarnetVetsModule,
    VetConsultModule,
    AdminMetricsModule,
    AuditMetricsModule,
    ActionLogModule,
    MailModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
