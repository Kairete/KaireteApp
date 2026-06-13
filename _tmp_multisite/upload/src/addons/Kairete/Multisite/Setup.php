<?php

namespace Kairete\Multisite;

use Kairete\Multisite\Service\Member\TenantMemberRouteSetup;
use Kairete\Multisite\Service\Member\TenantMemberWidgetPositions;
use XF\AddOn\AbstractSetup;
use XF\Db\Schema\Alter;
use XF\Db\Schema\Create;

class Setup extends AbstractSetup
{
	public function install(array $stepParams = [])
	{
		$this->createTables();
		$this->enablePublicListeners();
		TenantMemberRouteSetup::upsertRoutes(\XF::app());
		$this->safeUpsertTenantMemberWidgetPositions();
	}

	public function postInstall(array &$stateChanges)
	{
		$this->safeUpsertTenantMemberWidgetPositions();
	}

	public function upgrade(array $stepParams = [])
	{
		$this->createTables();
		$this->ensureTenantDomainUrlSchemeColumn();
		$this->enablePublicListeners();
	}

	/**
	 * @param int|string $previousVersion
	 */
	public function postUpgrade($previousVersion, array &$stateChanges): void
	{
		$this->safeUpsertTenantMemberWidgetPositions();
	}

	public function onActiveChange($newActive, array &$jobList = [])
	{
		if ($newActive)
		{
			$this->safeUpsertTenantMemberWidgetPositions();
		}
	}

	protected function safeUpsertTenantMemberWidgetPositions(): void
	{
		try
		{
			TenantMemberWidgetPositions::ensureStaticPositions(\XF::app());
			TenantMemberWidgetPositions::migrateLegacyPositions(\XF::app());
		}
		catch (\Throwable $e)
		{
			\XF::logException($e, false, 'Multisite widget positions upsert: ');
		}
	}

	public function upgrade1000023Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000024Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000025Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000026Step1(array $stepParams = [])
	{
		$this->purgeAdminTemplates();
		$this->safeUpgradeCleanup();

		return true;
	}

	public function upgrade1000028Step1(array $stepParams = [])
	{
		$this->purgeAdminTemplates();

		return true;
	}

	public function upgrade1000029Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000030Step1(array $stepParams = [])
	{
		$this->purgeAdminTemplates();

		return true;
	}

	public function upgrade1000031Step1(array $stepParams = [])
	{
		$this->purgeAdminTemplates();

		return true;
	}

	public function upgrade1000032Step1(array $stepParams = [])
	{
		$this->purgeAdminTemplates();

		return true;
	}

	public function upgrade1000033Step1(array $stepParams = [])
	{
		$this->purgeAdminTemplates();

		return true;
	}

	public function upgrade1000034Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000035Step1(array $stepParams = [])
	{
		$this->purgeAdminTemplates();
		$this->removeOrphanTenantDomains();

		return true;
	}

	public function upgrade1000036Step1(array $stepParams = [])
	{
		$this->purgeAdminTemplates();

		return true;
	}

	public function upgrade1000037Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();

		return true;
	}

	public function upgrade1000038Step1(array $stepParams = [])
	{
		$this->purgeAdminTemplates();

		return true;
	}

	public function upgrade1000039Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();

		return true;
	}

	public function upgrade1000040Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();

		return true;
	}

	public function upgrade1000041Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();

		return true;
	}

	public function upgrade1000042Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();

		return true;
	}

	public function upgrade1000043Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();

		return true;
	}

	public function upgrade1000044Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();

		return true;
	}

	public function upgrade1000045Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();

		return true;
	}

	public function upgrade1000046Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();
		$this->normalizeStoredDomainHosts();

		return true;
	}

	public function upgrade1000047Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();
		$this->normalizeStoredDomainHosts();

		return true;
	}

	public function upgrade1000048Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000049Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000050Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000051Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();
		$this->normalizeStoredDomainHosts();

		return true;
	}

	public function upgrade1000060Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();
		$this->normalizeStoredDomainHosts();

		return true;
	}

	public function upgrade1000061Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000062Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000070Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000071Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000072Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000073Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000074Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000075Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000076Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000077Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000078Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000080Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000081Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000082Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000083Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000084Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000085Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000086Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000087Step1(array $stepParams = [])
	{
		$this->createSsoRunTable();

		return true;
	}

	public function upgrade1000088Step1(array $stepParams = [])
	{
		$this->createSsoRunTable();

		return true;
	}

	public function upgrade1000089Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000090Step1(array $stepParams = [])
	{
		$this->ensureTenantDomainUrlSchemeColumn();

		return true;
	}

	public function upgrade1000091Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000092Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000093Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000094Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000095Step1(array $stepParams = [])
	{
		\Kairete\Multisite\Repository\ContentCanonical::resetCache();

		return true;
	}

	public function upgrade1000096Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000097Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000098Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000099Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000100Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000101Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000102Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000103Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000104Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000105Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000106Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000107Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000108Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000109Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000110Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000111Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000112Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000113Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000114Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000115Step1(array $stepParams = [])
	{
		$this->ensureTenantDomainUrlSchemeColumn();

		return true;
	}

	public function upgrade1000116Step1(array $stepParams = [])
	{
		$this->ensureTenantDomainUrlSchemeColumn();

		return true;
	}

	public function upgrade1000117Step1(array $stepParams = [])
	{
		$this->ensureTenantDomainUrlSchemeColumn();

		return true;
	}

	public function upgrade1000118Step1(array $stepParams = [])
	{
		$this->ensureTenantDomainUrlSchemeColumn();

		return true;
	}

	public function upgrade1000119Step1(array $stepParams = [])
	{
		$this->ensureTenantDomainUrlSchemeColumn();
		$this->enablePublicListeners();

		return true;
	}

	public function upgrade1000120Step1(array $stepParams = [])
	{
		\Kairete\Multisite\Repository\ContentCanonical::resetCache();

		return true;
	}

	public function upgrade1000121Step1(array $stepParams = [])
	{
		\Kairete\Multisite\Repository\ContentCanonical::resetCache();

		return true;
	}

	public function upgrade1000122Step1(array $stepParams = [])
	{
		\Kairete\Multisite\Repository\ContentCanonical::resetCache();

		return true;
	}

	public function upgrade1000123Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000124Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000125Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000126Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000127Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000128Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000129Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000130Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000131Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000132Step1(array $stepParams = [])
	{
		$this->purgeAdminTemplates();
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000133Step1(array $stepParams = [])
	{
		$this->purgeAdminTemplates();
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000134Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000135Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000136Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000137Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000138Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000139Step1(array $stepParams = [])
	{
		$this->createRegistrationFieldTables();
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000140Step1(array $stepParams = [])
	{
		$this->createRegistrationFieldTables();
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000141Step1(array $stepParams = [])
	{
		$this->createRegistrationFieldTables();
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000142Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000143Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000144Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000145Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000146Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000147Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000148Step1(array $stepParams = [])
	{
		$this->purgeRegisterFormTemplateModifications();
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000149Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000150Step1(array $stepParams = [])
	{
		$this->purgeRegisterFormTemplateModifications();
		$this->disableRegisterClassExtension();
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000151Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000152Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000153Step1(array $stepParams = [])
	{
		$this->purgeRegisterFormTemplateModifications();
		$this->disableRegisterClassExtension();
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000154Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();

		return true;
	}

	public function upgrade1000155Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000156Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000157Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();

		return true;
	}

	public function upgrade1000158Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->disableRegisterControllerPostDispatchListener();

		return true;
	}

	public function upgrade1000159Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->disableRegisterControllerPostDispatchListener();

		return true;
	}

	public function upgrade1000160Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();
		$this->disableRegisterControllerPostDispatchListener();

		return true;
	}

	public function upgrade1000161Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000162Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000163Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();
		$this->disableRegisterControllerPostDispatchListener();

		return true;
	}

	public function upgrade1000164Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000166Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000167Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000168Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000169Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000170Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000171Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000172Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000173Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000174Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000175Step1(array $stepParams = [])
	{
		return true;
	}

	public function upgrade1000176Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000177Step1(array $stepParams = [])
	{
		$this->purgeAdminTemplates();
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000178Step1(array $stepParams = [])
	{
		$this->purgeAdminTemplates();
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000179Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000180Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000181Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000182Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000183Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000184Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();
		TenantMemberRouteSetup::upsertRoutes(\XF::app());

		return true;
	}

	public function upgrade1000185Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000186Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000187Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000188Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000189Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();
		$this->safeUpsertTenantMemberWidgetPositions();

		return true;
	}

	public function upgrade1000190Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();
		$this->safeUpsertTenantMemberWidgetPositions();

		return true;
	}

	public function upgrade1000191Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();
		$this->safeUpsertTenantMemberWidgetPositions();

		return true;
	}

	public function upgrade1000192Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();

		return true;
	}

	public function upgrade1000193Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();
		$this->safeUpsertTenantMemberWidgetPositions();

		return true;
	}

	public function upgrade1000194Step1(array $stepParams = [])
	{
		$this->enablePublicListeners();
		$this->enableClassExtensions();
		$this->safeUpsertTenantMemberWidgetPositions();

		return true;
	}

	public function upgrade1000195Step1(array $stepParams = [])
	{
		$this->createMobileDeviceSessionTable();

		return true;
	}

	public function uninstall(array $stepParams = [])
	{
		$sm = $this->schemaManager();
		$sm->dropTable('xf_ms_mobile_device_session');
		$sm->dropTable('xf_ms_sso_run');
		$sm->dropTable('xf_ms_reg_user_applied');
		$sm->dropTable('xf_ms_reg_choice_action');
		$sm->dropTable('xf_ms_tenant_reg_field');
		$sm->dropTable('xf_ms_tenant_staff');
		$sm->dropTable('xf_ms_registration_profile');
		$sm->dropTable('xf_ms_tenant_mapping');
		$sm->dropTable('xf_ms_tenant_domain');
		$sm->dropTable('xf_ms_tenant');
	}

	protected function createSsoRunTable(): void
	{
		$sm = $this->schemaManager();
		if ($sm->tableExists('xf_ms_sso_run'))
		{
			return;
		}

		$sm->createTable('xf_ms_sso_run', function (Create $table) {
			$table->addColumn('run_id', 'char', 32);
			$table->addColumn('run_data', 'mediumblob');
			$table->addColumn('expiry_date', 'int')->setDefault(0);
			$table->addPrimaryKey('run_id');
			$table->addKey('expiry_date');
		});
	}

	protected function createMobileDeviceSessionTable(): void
	{
		$sm = $this->schemaManager();
		if ($sm->tableExists('xf_ms_mobile_device_session'))
		{
			return;
		}

		$sm->createTable('xf_ms_mobile_device_session', function (Create $table) {
			$table->addColumn('session_id', 'int')->autoIncrement();
			$table->addColumn('user_id', 'int')->setDefault(0);
			$table->addColumn('device_key', 'varchar', 128)->setDefault('');
			$table->addColumn('session_token', 'varchar', 64)->setDefault('');
			$table->addColumn('app_id', 'varchar', 100)->setDefault('');
			$table->addColumn('last_used_date', 'int')->setDefault(0);
			$table->addColumn('created_date', 'int')->setDefault(0);
			$table->addColumn('expires_date', 'int')->setDefault(0);
			$table->addPrimaryKey('session_id');
			$table->addUniqueKey('device_key');
			$table->addKey(['user_id', 'last_used_date']);
		});
	}

	protected function createTables(): void
	{
		$sm = $this->schemaManager();
		$this->createSsoRunTable();
		$this->createMobileDeviceSessionTable();

		if (!$sm->tableExists('xf_ms_tenant'))
		{
			$sm->createTable('xf_ms_tenant', function (Create $table) {
				$table->addColumn('tenant_id', 'int')->autoIncrement();
				$table->addColumn('title', 'varchar', 100)->setDefault('');
				$table->addColumn('slug', 'varchar', 100)->setDefault('');
				$table->addColumn('active', 'tinyint')->setDefault(0);
				$table->addColumn('homepage_layout', 'varchar', 50)->setDefault('feed');
				$table->addColumn('homepage_config', 'mediumblob')->nullable();
				$table->addColumn('newsfeed_group_id', 'int')->setDefault(0);
				$table->addColumn('registration_profile_id', 'int')->setDefault(0);
				$table->addColumn('created_date', 'int')->setDefault(0);
				$table->addPrimaryKey('tenant_id');
				$table->addUniqueKey('slug');
			});
		}

		if (!$sm->tableExists('xf_ms_tenant_domain'))
		{
			$sm->createTable('xf_ms_tenant_domain', function (Create $table) {
				$table->addColumn('domain_id', 'int')->autoIncrement();
				$table->addColumn('tenant_id', 'int');
				$table->addColumn('host', 'varchar', 255)->setDefault('');
				$table->addColumn('is_primary', 'tinyint')->setDefault(0);
				$table->addColumn('active', 'tinyint')->setDefault(1);
				$table->addColumn('verified', 'tinyint')->setDefault(0);
				$table->addColumn('url_scheme', 'varchar', 8)->setDefault('auto');
				$table->addPrimaryKey('domain_id');
				$table->addUniqueKey('host');
				$table->addKey('tenant_id');
			});
		}

		if (!$sm->tableExists('xf_ms_tenant_mapping'))
		{
			$sm->createTable('xf_ms_tenant_mapping', function (Create $table) {
				$table->addColumn('mapping_id', 'int')->autoIncrement();
				$table->addColumn('tenant_id', 'int');
				$table->addColumn('content_type', 'varchar', 50);
				$table->addColumn('content_id', 'int');
				$table->addColumn('role', 'varchar', 20)->setDefault('secondary');
				$table->addColumn('display_order', 'int')->setDefault(0);
				$table->addColumn('options', 'mediumblob')->nullable();
				$table->addPrimaryKey('mapping_id');
				$table->addUniqueKey(['tenant_id', 'content_type', 'content_id'], 'tenant_content');
				$table->addKey(['tenant_id', 'content_type']);
			});
		}

		if (!$sm->tableExists('xf_ms_registration_profile'))
		{
			$sm->createTable('xf_ms_registration_profile', function (Create $table) {
				$table->addColumn('profile_id', 'int')->autoIncrement();
				$table->addColumn('title', 'varchar', 100)->setDefault('');
				$table->addColumn('custom_field_ids', 'blob')->nullable();
				$table->addColumn('welcome_message', 'text')->nullable();
				$table->addColumn('redirect_route', 'varchar', 100)->setDefault('');
				$table->addPrimaryKey('profile_id');
			});
		}

		if (!$sm->tableExists('xf_ms_tenant_staff'))
		{
			$sm->createTable('xf_ms_tenant_staff', function (Create $table) {
				$table->addColumn('tenant_id', 'int');
				$table->addColumn('user_id', 'int');
				$table->addPrimaryKey(['tenant_id', 'user_id']);
			});
		}

		$this->createRegistrationFieldTables();

		$this->ensureTenantDomainUrlSchemeColumn();
	}

	protected function createRegistrationFieldTables(): void
	{
		$sm = $this->schemaManager();

		if (!$sm->tableExists('xf_ms_tenant_reg_field'))
		{
			$sm->createTable('xf_ms_tenant_reg_field', function (Create $table) {
				$table->addColumn('tenant_reg_field_id', 'int')->autoIncrement();
				$table->addColumn('tenant_id', 'int');
				$table->addColumn('field_id', 'varchar', 25);
				$table->addColumn('display_order', 'int')->setDefault(0);
				$table->addColumn('required', 'tinyint')->setDefault(1);
				$table->addColumn('active', 'tinyint')->setDefault(1);
				$table->addPrimaryKey('tenant_reg_field_id');
				$table->addUniqueKey(['tenant_id', 'field_id'], 'tenant_field');
				$table->addKey('tenant_id');
			});
		}

		if (!$sm->tableExists('xf_ms_reg_choice_action'))
		{
			$sm->createTable('xf_ms_reg_choice_action', function (Create $table) {
				$table->addColumn('choice_action_id', 'int')->autoIncrement();
				$table->addColumn('tenant_reg_field_id', 'int');
				$table->addColumn('choice_value', 'varchar', 100)->setDefault('');
				$table->addColumn('actions', 'mediumblob');
				$table->addPrimaryKey('choice_action_id');
				$table->addUniqueKey(['tenant_reg_field_id', 'choice_value'], 'field_choice');
			});
		}

		if (!$sm->tableExists('xf_ms_reg_user_applied'))
		{
			$sm->createTable('xf_ms_reg_user_applied', function (Create $table) {
				$table->addColumn('user_id', 'int');
				$table->addColumn('tenant_id', 'int');
				$table->addColumn('field_id', 'varchar', 25);
				$table->addColumn('choice_value', 'varchar', 100)->setDefault('');
				$table->addColumn('applied_snapshot', 'mediumblob');
				$table->addColumn('last_applied_date', 'int')->setDefault(0);
				$table->addPrimaryKey(['user_id', 'tenant_id', 'field_id']);
				$table->addKey('tenant_id');
			});
		}
	}

	protected function ensureTenantDomainUrlSchemeColumn(): void
	{
		\Kairete\Multisite\Service\Schema\TenantDomainSchema::ensureUrlSchemeColumn(\XF::app());
	}

	protected function purgeAdminTemplates(): void
	{
		try
		{
			$this->db()->delete(
				'xf_template',
				"addon_id = ? AND type = 'admin' AND title LIKE 'ms\\_%'",
				$this->addOn->addon_id
			);
		}
		catch (\Throwable $e)
		{
			\XF::logException($e, false, 'Kairete Multisite purge templates: ');
		}
	}

	protected function purgeRegisterFormTemplateModifications(): void
	{
		try
		{
			$this->db()->delete(
				'xf_template_modification',
				"addon_id = ? AND modification_key IN ('ms_register_tenant_fields', 'ms_register_tenant_fields_id')",
				$this->addOn->addon_id
			);
		}
		catch (\Throwable $e)
		{
			\XF::logException($e, false, 'Kairete Multisite purge register template mods: ');
		}
	}

	protected function enablePublicListeners(): void
	{
		try
		{
			$this->db()->update(
				'xf_code_event_listener',
				['active' => 1],
				"addon_id = ? AND event_id IN ('app_setup', 'app_pub_start_begin', 'app_pub_start', 'dispatcher_pre_dispatch', 'user_login', 'user_register', 'user_logout', 'controller_post_dispatch', 'templater_template_pre_render', 'templater_template_post_render')",
				$this->addOn->addon_id
			);
		}
		catch (\Throwable $e)
		{
			\XF::logException($e, false, 'Kairete Multisite enable listeners: ');
		}
	}

	protected function disableRegisterControllerPostDispatchListener(): void
	{
		try
		{
			$this->db()->update(
				'xf_code_event_listener',
				['active' => 0],
				"addon_id = ? AND event_id = 'controller_post_dispatch' AND callback_class = 'Kairete\\\\Multisite\\\\Listener' AND callback_method = 'controllerPostDispatch'",
				$this->addOn->addon_id
			);
		}
		catch (\Throwable $e)
		{
			\XF::logException($e, false, 'Kairete Multisite disable register post_dispatch listener: ');
		}
	}

	protected function disableRegisterClassExtension(): void
	{
		try
		{
			$this->db()->update(
				'xf_class_extension',
				['active' => 0],
				"addon_id = ? AND from_class = 'XF\\\\Pub\\\\Controller\\\\Register'",
				$this->addOn->addon_id
			);
		}
		catch (\Throwable $e)
		{
			\XF::logException($e, false, 'Kairete Multisite disable Register extension: ');
		}
	}

	protected function enableClassExtensions(): void
	{
		try
		{
			$this->db()->update(
				'xf_class_extension',
				['active' => 1],
				"addon_id = ? AND from_class IN ('XF\\\\Entity\\\\User', 'XF\\\\Entity\\\\UserProfile', 'XF\\\\Mvc\\\\Router', 'XF\\\\Mvc\\\\Dispatcher', 'XF\\\\Pub\\\\App', 'XF\\\\Pub\\\\Controller\\\\Index', 'XF\\\\Pub\\\\Controller\\\\Forum', 'XF\\\\Pub\\\\Controller\\\\Login', 'XF\\\\Pub\\\\Controller\\\\Logout', 'XF\\\\Pub\\\\Controller\\\\Register', 'XF\\\\ControllerPlugin\\\\Login', 'XF\\\\Service\\\\User\\\\Registration', 'XF\\\\Admin\\\\Controller\\\\Widget', 'XF\\\\Widget\\\\WidgetRenderer', 'Kairete\\\\SocialGroups\\\\Pub\\\\Controller\\\\Group')",
				$this->addOn->addon_id
			);
		}
		catch (\Throwable $e)
		{
			\XF::logException($e, false, 'Kairete Multisite enable class extensions: ');
		}
	}

	protected function normalizeStoredDomainHosts(): void
	{
		try
		{
			$rows = $this->db()->fetchAll('SELECT domain_id, host FROM xf_ms_tenant_domain');
			foreach ($rows as $row)
			{
				$normalized = \Kairete\Multisite\Service\Tenant\HostResolver::normalizeHostString((string) $row['host']);
				if ($normalized !== '' && $normalized !== $row['host'])
				{
					$this->db()->update(
						'xf_ms_tenant_domain',
						['host' => $normalized],
						'domain_id = ?',
						$row['domain_id']
					);
				}
			}
		}
		catch (\Throwable $e)
		{
			\XF::logException($e, false, 'Kairete Multisite normalize domain hosts: ');
		}
	}

	protected function removeOrphanTenantDomains(): void
	{
		try
		{
			$this->db()->query('
				DELETE d FROM xf_ms_tenant_domain AS d
				LEFT JOIN xf_ms_tenant AS t ON (t.tenant_id = d.tenant_id)
				WHERE t.tenant_id IS NULL
			');
		}
		catch (\Throwable $e)
		{
			\XF::logException($e, false, 'Kairete Multisite orphan domains: ');
		}
	}

	protected function safeUpgradeCleanup(): void
	{
		try
		{
			$db = $this->db();
			$this->enablePublicListeners();
			$db->update(
				'xf_admin_navigation',
				['link' => 'ms-tenants'],
				"navigation_id = 'msPlatform' AND addon_id = ?",
				$this->addOn->addon_id
			);
		}
		catch (\Throwable $e)
		{
			\XF::logException($e, false, 'Kairete Multisite safe upgrade: ');
		}
	}
}
