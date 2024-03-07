// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22HUD extends SHHud
	Config(SH22);


function InitHudItems()
{
	AddHudItem(class'SH22HUDItem_Coins', self);
	AddHudItem(class'SH22HUDItem_HealthBar', self);
	AddHudItem(class'HudItemHealthBossPib', self);
	AddHudItem(class'SHHudGameTimer', self);
	AddHudItem(class'SHHudPotionTimer', self);
	AddHudItem(class'SH22HUDItem_Potions', self);
	AddHudItem(class'SH22HUDItem_TimesUp', self);
	AddHudItem(class'SH22HUDItem_Info', self);
}