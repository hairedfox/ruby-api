require_relative('./base_controller.rb')
require_relative('../models/feedback.rb')
require 'json'

class FeedbacksController < BaseController
  def create
    error = authorize!
    return error if error

    result = Feedback.create(
      comment: body_params['comment'],
      target_id: body_params['target_id'],
      target_type: body_params['target_type'],
      user_id: current_user[:id]
    )

    if result[:success]
      feedbacks = Feedback.by_user_id(current_user[:id]).all

      return response_with(code: 200, data: [feedbacks.to_json])
    end

    response_with(code: 422, data: [{ errors: result[:errors] }.to_json])
  end
end
