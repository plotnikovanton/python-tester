class TasksController < ApplicationController
  before_action :set_task, only: %i(show edit update destroy)
  before_action :admin_only, except: %i(index show)

  # GET /tasks
  def index
    @tasks = Task.all
  end

  # GET /tasks/1
  def show
    if current_user
      @submissions = Submission.find_for_user_and_task current_user, @task
    end
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        save_tests JSON.parse(params[:tests])
        format.html { redirect_to @task, notice: 'Task created.' }
        format.json { render :show, status: :ok, location: @task }
      else
        format.json { render json: @task.errors, status: 500 }
      end
    end
  end

  # PATCH/PUT /tasks/1
  def update
    respond_to do |format|
      if @task.update(task_params)
        save_tests JSON.parse(params[:tests])
        format.html { redirect_to @task, notice: 'Task was updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: 'Task was destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def save_tests(tests)
      added = []
      tests.each do |test|
        t = test['inedx'] ? Test.find(test[:index]) : Test.new
        t.in = test['in']
        t.out = test['out']
        t.task = @task
        added << t.id if t.save
      end
      Test.where(task: @task).where.not(id: added).delete_all
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:title, :body, :format, :tests)
    end
end
