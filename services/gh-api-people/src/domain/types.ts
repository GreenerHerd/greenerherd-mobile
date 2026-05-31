export type FarmRole = 'OWNER' | 'MANAGER' | 'FARM_HAND' | 'VET';
export type PreferredLang = 'EN' | 'AR' | 'UR' | 'FR';
export type InviteDeliveryChannel = 'EMAIL' | 'WHATSAPP' | 'BOTH';

export interface User {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  preferred_lang: PreferredLang;
  created_at: string;
}

export interface FarmUser {
  id: string;
  farm_id: string;
  user_id: string;
  farm_role: FarmRole;
  is_active: boolean;
  last_active_at: string | null;
}

export interface GroupUserAccess {
  id: string;
  group_id: string;
  user_id: string;
  can_manage: boolean;
}

export interface InviteUserInput {
  name: string;
  email?: string;
  phone?: string;
  farm_role: FarmRole;
  preferred_lang?: PreferredLang;
  delivery_channel: InviteDeliveryChannel;
}

export interface FarmMemberView {
  farm_user: FarmUser;
  user: User;
  group_ids: string[];
}
