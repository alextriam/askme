class QuestionsController < ApplicationController
  before_action :load_question, only: [:edit, :update, :destroy]
  before_action :authorize_user, except: [:create]

  def create
    @question = Question.new(question_params)
    @question.author_id = current_user&.id

    if @question.save
      # После сохранения вопроса редиректим на пользователя
      redirect_to user_path(@question.user), notice: 'Вопрос задан'
    else
      render :edit
    end
  end

  def update
    if @question.update(question_params)
      # Если обновил вопрос, то тоже редиректим на страницу юзера
      redirect_to user_path(@question.user), notice: 'Вопрос сохранен'
    else
      render :edit
    end
  end

  def destroy
    user = @question.user

    # Удаляем вопрос
    @question.destroy

    # Отправляем пользователя на страницу адресата вопроса с сообщением
    redirect_to user_path(user), notice: 'Вопрос удален :('
  end

  private

  def question_params
    # Защита от уязвимости: если текущий пользователь — адресат вопроса,
    # он может менять ответы на вопрос, ему доступно и поле :answer.
    if current_user.present? &&
      params[:question][:user_id].to_i == current_user.id
      params.require(:question).permit(:user_id, :text, :answer)
    else
      params.require(:question).permit(:user_id, :text)
    end
  end

  def load_question
    @question = Question.find(params[:id])
  end

  def authorize_user
    reject_user unless @question.user == current_user
  end
end
