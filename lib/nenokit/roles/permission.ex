defmodule Nenokit.Roles.Permission do
  @moduledoc """
  Permissions module to get all the permissions
  """

  def get_permissions do
    [
      "manage_pages",
      "manage_blogs",
      "manage_media",
      "manage_surveys",
      "manage_users",
      "manage_roles",
      "manage_settings",
      "manage_subscribers"
    ]
  end
end
