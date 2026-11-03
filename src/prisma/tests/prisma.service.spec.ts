import { PrismaService } from '../services/prisma.service';

describe('PrismaService', () => {
  const originalUrl = process.env.DATABASE_URL;

  afterEach(() => {
    process.env.DATABASE_URL = originalUrl;
    jest.restoreAllMocks();
  });

  it('should fail when DATABASE_URL is not defined', () => {
    delete process.env.DATABASE_URL;

    expect(() => new PrismaService()).toThrow(
      'La variable de entorno DATABASE_URL no está definida.',
    );
  });

  describe('with DATABASE_URL', () => {
    let service: PrismaService;

    beforeEach(() => {
      process.env.DATABASE_URL =
        'postgresql://user:password@localhost:5432/petcontrol';
      service = new PrismaService();
    });

    it('should connect and check the database on module init', async () => {
      const connect = jest
        .spyOn(service, '$connect')
        .mockResolvedValue(undefined);
      const query = jest.spyOn(service, '$queryRaw').mockResolvedValue([]);

      await service.onModuleInit();

      expect(connect).toHaveBeenCalledTimes(1);
      expect(query).toHaveBeenCalledTimes(1);
    });

    it('should fail on module init when the database is unreachable', async () => {
      jest.spyOn(service, '$connect').mockResolvedValue(undefined);
      jest
        .spyOn(service, '$queryRaw')
        .mockRejectedValue(new Error('connect ECONNREFUSED'));

      await expect(service.onModuleInit()).rejects.toThrow(
        'connect ECONNREFUSED',
      );
    });

    it('should disconnect on module destroy', async () => {
      const disconnect = jest
        .spyOn(service, '$disconnect')
        .mockResolvedValue(undefined);

      await service.onModuleDestroy();

      expect(disconnect).toHaveBeenCalledTimes(1);
    });
  });
});
