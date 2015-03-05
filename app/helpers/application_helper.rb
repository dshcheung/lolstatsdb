module ApplicationHelper
  # shared methods for begin/rescue
  def rescue_me(e)
    return 2
  end
  #   case e.io.status[0]
  #   when "400"
  #     return 2
  #   when "401"
  #     return 2
  #   when "404"
  #     return 2
  #   else 
  #     return attempt_retry
  #   end
  # end

  def attempt_retry
    @tries += 1
    if @tries < 3
      sleep 1
      return 1
    else
      return 2
    end
  end
end
