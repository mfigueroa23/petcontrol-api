import { Test, TestingModule } from '@nestjs/testing';
import { AppModule } from './app.module';
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

describe('AppModule', () => {
  let moduleRef: TestingModule;

  beforeAll(async () => {
    moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
  });

  afterAll(async () => {
    await moduleRef.close();
  });

  it.each([
    ['AuthModule', AuthModule],
    ['AccountsModule', AccountsModule],
    ['VetRequestsModule', VetRequestsModule],
    ['UserAdminModule', UserAdminModule],
    ['AccessControlModule', AccessControlModule],
    ['PetsModule', PetsModule],
    ['PetTypesModule', PetTypesModule],
    ['HistoryModule', HistoryModule],
    ['CarnetVetsModule', CarnetVetsModule],
    ['VetConsultModule', VetConsultModule],
    ['AdminMetricsModule', AdminMetricsModule],
    ['AuditMetricsModule', AuditMetricsModule],
    ['ActionLogModule', ActionLogModule],
    ['MailModule', MailModule],
  ])('should register %s', (_name, moduleClass) => {
    expect(moduleRef.get(moduleClass)).toBeInstanceOf(moduleClass);
  });
});
