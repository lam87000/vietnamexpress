class Admin::ClosuresController < Admin::BaseController
  before_action :set_closure, only: [:update, :destroy]

  def index
    @closure = Closure.new
    @closures = Closure.order(start_on: :asc)
  end

  def create
    @closure = Closure.new(closure_params)
    @closure.reason = "Congés" if @closure.reason.blank?

    if @closure.save
      flash[:notice] = "Fermeture programmée du #{@closure.formatted_range}."
    else
      flash[:alert] = @closure.errors.full_messages.to_sentence
    end

    redirect_to admin_closures_path
  end

  def update
    if @closure.update(closure_params)
      flash[:notice] = "Fermeture mise à jour."
    else
      flash[:alert] = @closure.errors.full_messages.to_sentence
    end

    redirect_to admin_closures_path
  end

  def destroy
    @closure.destroy
    flash[:notice] = "Fermeture supprimée."
    redirect_to admin_closures_path
  end

  private

  def set_closure
    @closure = Closure.find(params[:id])
  end

  def closure_params
    params.require(:closure).permit(:start_on, :end_on, :reason)
  end
end
