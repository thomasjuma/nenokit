defmodule NenokitWeb.AdminSurveyController do
  use NenokitWeb, :controller

  alias Nenokit.{Surveys, Surveys.SurveySubmissions, Surveys.Workflows, Surveys.WorkflowStages, AuditTrails, Roles}

  def index(conn, _params) do
    surveys = Surveys.list_surveys
    render(conn, "index.html", surveys: surveys)
  end

  def new(conn, _params) do
    changeset = Surveys.change_survey
    roles = Roles.list_roles |> Enum.map(fn role -> {role.name, role.id} end)
    render(conn, "new.html", changeset: changeset, survey: nil, stages: get_stage_options(), roles: roles)
  end

  def create(conn, %{"survey" => params}) do
    case Surveys.create_survey(params) do
      {:ok, survey} ->
        # Log action in audit trial
        current_user = conn.assigns.current_user
        AuditTrails.create_audit_trail(current_user, %{"action" => "Created a new survey", "module" => "admin_survey", "record_id" => survey.id})

        conn
        |> put_flash(:success, "Survey created successfully")
        |> redirect(to: Routes.admin_survey_path(conn, :show, survey))
      {:error, changeset} ->
        roles = Roles.list_roles |> Enum.map(fn role -> {role.name, role.id} end)
        render(conn, "new.html", changeset: changeset, survey: nil, stages: get_stage_options(), roles: roles)
    end
  end

  def show(conn, %{"id" => survey_id}) do
    survey = Surveys.get_survey(survey_id)
    submissions = SurveySubmissions.list_survey_submissions_by_survey(survey.id)
    render(conn, "show.html", survey: survey, submissions: submissions)
  end

  def show_submission(conn, %{"id" => survey_id, "submission_id" => submission_id}) do
    survey = Surveys.get_survey(survey_id)
    submission = SurveySubmissions.get_survey_submission(submission_id)
    render(conn, "show_submission.html", survey: survey, submission: submission)
  end

  def edit(conn, %{"id" => survey_id}) do
    survey = Surveys.get_survey(survey_id)
    changeset = Surveys.change_survey(survey)
    roles = Roles.list_roles |> Enum.map(fn role -> {role.name, role.id} end)
    render(conn, "edit.html", survey: survey, changeset: changeset, stages: get_stage_options(), roles: roles)
  end

  def update(conn, %{"id" => survey_id, "survey" => survey_params}) do
    survey = Surveys.get_survey(survey_id)
    case Surveys.update_survey(survey, survey_params) do
      {:ok, survey} ->
        # Log action in audit trial
        current_user = conn.assigns.current_user
        AuditTrails.create_audit_trail(current_user, %{"action" => "Updated a survey", "module" => "admin_survey", "record_id" => survey.id})

        conn
        |> put_flash(:info, "Survey updated successfully.")
        |> redirect(to: Routes.admin_survey_path(conn, :show, survey))

      {:error, %Ecto.Changeset{} = changeset} ->
        roles = Roles.list_roles |> Enum.map(fn role -> {role.name, role.id} end)
        render(conn, "edit.html", survey: survey, changeset: changeset, stages: get_stage_options(), roles: roles)
    end
  end

  def delete(conn, %{"id" => survey_id}) do
    survey = Surveys.get_survey(survey_id)
    {:ok, _survey} = Surveys.delete_survey(survey)

    # Log action in audit trial
    current_user = conn.assigns.current_user
    AuditTrails.create_audit_trail(current_user, %{"action" => "Deleted a survey", "module" => "admin_survey", "record_id" => survey.id})

    conn
    |> put_flash(:info, "Survey deleted successfully.")
    |> redirect(to: Routes.admin_survey_path(conn, :index))
  end

  defp get_stage_options() do
    Workflows.list_workflows |> Enum.map(fn workflow ->
      stages = WorkflowStages.list_workflow_stages(workflow.id)
      {workflow.name, stages |> Enum.map(fn stage ->
        {stage.name, stage.id}
      end)}
    end)
  end
end
