require_relative './base_controller.rb'
require_relative '../models/rating.rb'

class RatingsController < BaseController
  def create
    error = authorize!
    return error if error

    result = Rating.create(
      post_id: body_params['post_id'],
      rating: body_params['rating'],
      user_id: current_user[:id]
    )

    if result[:success]
      avg_rating = Rating.average(post_id: body_params['post_id'])

      return response_with(code: 200, data: [{ avg_rating: }.to_json])
    end

    response_with(code: 422, data: [{ errors: result[:errors] }.to_json])
  end
end
