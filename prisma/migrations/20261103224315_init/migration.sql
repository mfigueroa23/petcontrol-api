-- CreateEnum
CREATE TYPE "account_status" AS ENUM ('pending_confirmation', 'enabled', 'disabled');

-- CreateEnum
CREATE TYPE "role" AS ENUM ('user', 'vet', 'admin', 'auditor');

-- CreateEnum
CREATE TYPE "account_token_type" AS ENUM ('email_confirmation', 'password_reset', 'email_change');

-- CreateEnum
CREATE TYPE "vet_role_request_status" AS ENUM ('pending', 'approved', 'rejected');

-- CreateEnum
CREATE TYPE "pet_sex" AS ENUM ('male', 'female');

-- CreateEnum
CREATE TYPE "deworming_kind" AS ENUM ('internal', 'external');

-- CreateEnum
CREATE TYPE "admin_action_type" AS ENUM ('role_assigned', 'role_removed', 'account_deactivated', 'account_reactivated', 'rut_corrected', 'vet_request_approved', 'vet_request_rejected');

-- CreateTable
CREATE TABLE "accounts" (
    "id" UUID NOT NULL,
    "full_name" TEXT NOT NULL,
    "rut" VARCHAR(10) NOT NULL,
    "email" VARCHAR(254) NOT NULL,
    "password_hash" TEXT NOT NULL,
    "birth_date" DATE NOT NULL,
    "status" "account_status" NOT NULL DEFAULT 'pending_confirmation',
    "privacy_accepted_at" TIMESTAMPTZ(3) NOT NULL,
    "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "account_roles" (
    "account_id" UUID NOT NULL,
    "role" "role" NOT NULL,

    CONSTRAINT "account_roles_pkey" PRIMARY KEY ("account_id","role")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" UUID NOT NULL,
    "account_id" UUID NOT NULL,
    "token_hash" TEXT NOT NULL,
    "last_activity_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "account_tokens" (
    "id" UUID NOT NULL,
    "account_id" UUID NOT NULL,
    "type" "account_token_type" NOT NULL,
    "token_hash" TEXT NOT NULL,
    "new_email" VARCHAR(254),
    "expires_at" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "account_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vet_role_requests" (
    "id" UUID NOT NULL,
    "account_id" UUID NOT NULL,
    "status" "vet_role_request_status" NOT NULL DEFAULT 'pending',
    "rejection_reason" TEXT,
    "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolved_at" TIMESTAMPTZ(3),

    CONSTRAINT "vet_role_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pet_types" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "pet_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pets" (
    "id" UUID NOT NULL,
    "owner_id" UUID NOT NULL,
    "pet_type_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "breed" TEXT,
    "color" TEXT,
    "chip_number" VARCHAR(15),
    "sterilized" BOOLEAN,
    "birth_date" DATE,
    "sex" "pet_sex",

    CONSTRAINT "pets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pet_vets" (
    "pet_id" UUID NOT NULL,
    "entered_name" TEXT,
    "entered_rut" VARCHAR(10),
    "entered_phone" VARCHAR(12),
    "linked_account_id" UUID,
    "link_declined" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "pet_vets_pkey" PRIMARY KEY ("pet_id")
);

-- CreateTable
CREATE TABLE "vaccines" (
    "id" UUID NOT NULL,
    "pet_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "applied_on" DATE NOT NULL,
    "next_dose_on" DATE,

    CONSTRAINT "vaccines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "dewormings" (
    "id" UUID NOT NULL,
    "pet_id" UUID NOT NULL,
    "product" TEXT NOT NULL,
    "kind" "deworming_kind" NOT NULL,
    "applied_on" DATE NOT NULL,
    "next_dose_on" DATE,

    CONSTRAINT "dewormings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "food_purchases" (
    "id" UUID NOT NULL,
    "pet_id" UUID NOT NULL,
    "product" TEXT NOT NULL,
    "purchased_on" DATE NOT NULL,
    "quantity_kg" DECIMAL(6,2) NOT NULL,
    "price_clp" INTEGER,

    CONSTRAINT "food_purchases_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "treat_purchases" (
    "id" UUID NOT NULL,
    "pet_id" UUID NOT NULL,
    "product" TEXT NOT NULL,
    "purchased_on" DATE NOT NULL,
    "quantity_units" INTEGER NOT NULL,
    "price_clp" INTEGER,

    CONSTRAINT "treat_purchases_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "weights" (
    "id" UUID NOT NULL,
    "pet_id" UUID NOT NULL,
    "measured_on" DATE NOT NULL,
    "weight_kg" DECIMAL(5,2) NOT NULL,

    CONSTRAINT "weights_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "admin_actions" (
    "id" UUID NOT NULL,
    "actor_account_id" UUID NOT NULL,
    "target_account_id" UUID NOT NULL,
    "action" "admin_action_type" NOT NULL,
    "occurred_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "admin_actions_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "accounts_rut_key" ON "accounts"("rut");

-- CreateIndex
CREATE UNIQUE INDEX "accounts_email_key" ON "accounts"("email");

-- CreateIndex
CREATE UNIQUE INDEX "sessions_token_hash_key" ON "sessions"("token_hash");

-- CreateIndex
CREATE INDEX "sessions_account_id_idx" ON "sessions"("account_id");

-- CreateIndex
CREATE UNIQUE INDEX "account_tokens_token_hash_key" ON "account_tokens"("token_hash");

-- CreateIndex
CREATE INDEX "account_tokens_account_id_idx" ON "account_tokens"("account_id");

-- CreateIndex
CREATE INDEX "vet_role_requests_account_id_idx" ON "vet_role_requests"("account_id");

-- CreateIndex
CREATE INDEX "vet_role_requests_status_idx" ON "vet_role_requests"("status");

-- CreateIndex
CREATE UNIQUE INDEX "pets_chip_number_key" ON "pets"("chip_number");

-- CreateIndex
CREATE INDEX "pets_owner_id_idx" ON "pets"("owner_id");

-- CreateIndex
CREATE INDEX "pets_pet_type_id_idx" ON "pets"("pet_type_id");

-- CreateIndex
CREATE INDEX "pet_vets_entered_rut_idx" ON "pet_vets"("entered_rut");

-- CreateIndex
CREATE INDEX "pet_vets_linked_account_id_idx" ON "pet_vets"("linked_account_id");

-- CreateIndex
CREATE INDEX "vaccines_pet_id_applied_on_idx" ON "vaccines"("pet_id", "applied_on");

-- CreateIndex
CREATE INDEX "dewormings_pet_id_applied_on_idx" ON "dewormings"("pet_id", "applied_on");

-- CreateIndex
CREATE INDEX "food_purchases_pet_id_purchased_on_idx" ON "food_purchases"("pet_id", "purchased_on");

-- CreateIndex
CREATE INDEX "treat_purchases_pet_id_purchased_on_idx" ON "treat_purchases"("pet_id", "purchased_on");

-- CreateIndex
CREATE INDEX "weights_pet_id_measured_on_idx" ON "weights"("pet_id", "measured_on");

-- CreateIndex
CREATE INDEX "admin_actions_occurred_at_idx" ON "admin_actions"("occurred_at");

-- AddForeignKey
ALTER TABLE "account_roles" ADD CONSTRAINT "account_roles_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "account_tokens" ADD CONSTRAINT "account_tokens_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vet_role_requests" ADD CONSTRAINT "vet_role_requests_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pets" ADD CONSTRAINT "pets_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pets" ADD CONSTRAINT "pets_pet_type_id_fkey" FOREIGN KEY ("pet_type_id") REFERENCES "pet_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pet_vets" ADD CONSTRAINT "pet_vets_pet_id_fkey" FOREIGN KEY ("pet_id") REFERENCES "pets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pet_vets" ADD CONSTRAINT "pet_vets_linked_account_id_fkey" FOREIGN KEY ("linked_account_id") REFERENCES "accounts"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vaccines" ADD CONSTRAINT "vaccines_pet_id_fkey" FOREIGN KEY ("pet_id") REFERENCES "pets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dewormings" ADD CONSTRAINT "dewormings_pet_id_fkey" FOREIGN KEY ("pet_id") REFERENCES "pets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "food_purchases" ADD CONSTRAINT "food_purchases_pet_id_fkey" FOREIGN KEY ("pet_id") REFERENCES "pets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "treat_purchases" ADD CONSTRAINT "treat_purchases_pet_id_fkey" FOREIGN KEY ("pet_id") REFERENCES "pets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "weights" ADD CONSTRAINT "weights_pet_id_fkey" FOREIGN KEY ("pet_id") REFERENCES "pets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ---------------------------------------------------------------------------
-- SQL manual (ADR-005): restricciones que el esquema de Prisma no expresa.
-- Las migraciones siguientes deben conservarlas.
-- ---------------------------------------------------------------------------

-- El nombre de un tipo de mascota no se repite, sin distinguir mayúsculas (SRS 3.5, REQ-075).
CREATE UNIQUE INDEX "pet_types_name_lower_key" ON "pet_types" (lower("name"));

-- Una mascota tiene como máximo un peso por mes calendario (REQ-046).
-- La conversión a timestamp hace que date_trunc sea inmutable y se pueda indexar.
CREATE UNIQUE INDEX "weights_pet_id_month_key" ON "weights" ("pet_id", date_trunc('month', "measured_on"::timestamp));

-- Una cuenta tiene como máximo una solicitud pendiente del rol Veterinario (REQ-018).
CREATE UNIQUE INDEX "vet_role_requests_account_id_pending_key" ON "vet_role_requests" ("account_id") WHERE "status" = 'pending';

-- Pesos, cantidades y precios mayores que cero (REQ-049). Un precio no informado (NULL) se acepta.
ALTER TABLE "food_purchases" ADD CONSTRAINT "food_purchases_quantity_kg_check" CHECK ("quantity_kg" > 0);
ALTER TABLE "food_purchases" ADD CONSTRAINT "food_purchases_price_clp_check" CHECK ("price_clp" > 0);
ALTER TABLE "treat_purchases" ADD CONSTRAINT "treat_purchases_quantity_units_check" CHECK ("quantity_units" > 0);
ALTER TABLE "treat_purchases" ADD CONSTRAINT "treat_purchases_price_clp_check" CHECK ("price_clp" > 0);
ALTER TABLE "weights" ADD CONSTRAINT "weights_weight_kg_check" CHECK ("weight_kg" > 0);

-- ---------------------------------------------------------------------------
-- Datos iniciales: tipos de mascota disponibles desde el inicio (SRS 1.2).
-- ---------------------------------------------------------------------------

INSERT INTO "pet_types" ("id", "name", "active") VALUES
  (gen_random_uuid(), 'Perro', true),
  (gen_random_uuid(), 'Gato', true);
