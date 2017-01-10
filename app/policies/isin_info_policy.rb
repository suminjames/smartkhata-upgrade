# class IsinInfoPolicy < ApplicationPolicy


class IsinInfoPolicy < ApplicationPolicy
  attr_reader :current_user, :model

  permit_conditional_access_to_employee_and_above :index, :show, :new, :combobox_ajax_filter

  permit_custom_access :employee_and_above, new_isin_info_path, [:create, :edit, :update, :destroy]
end