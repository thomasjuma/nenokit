defmodule Nenokit.Surveys.SurveySubscriber do
  use Ecto.Schema
  import Ecto.Changeset

  alias Nenokit.{Accounts.User, Surveys.Survey, Surveys.SurveySubmission}

  schema "survey_subscriber" do
    field :subscription_notes, :string
    field :sent, :boolean, default: false
    field :submitted, :boolean, default: false
    belongs_to :user, User
    belongs_to :survey, Survey
    belongs_to :survey_submission, SurveySubmission

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:user_id, :survey_id, :subscription_notes, :sent, :submitted])
    |> validate_required([:user_id, :survey_id])
  end

end
