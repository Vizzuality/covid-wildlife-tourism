export type Pin = {
  id: number;
  name: string;
  latitude: number;
  longitude: number;
  website?: string;
  type: 'Community' | 'Enterprise';
  is_owner: boolean;
  public: boolean;
  can_edit: boolean;
  status?: string;
};
