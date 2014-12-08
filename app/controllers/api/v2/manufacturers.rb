module API
  module V2
    class Manufacturers < API::V2::Root
      include API::V2::Defaults

      resource :manufacturers do
        desc "All the manufacturers with pagination"
        paginate
        get '/', protected: false do
          paginate Manufacturer.scoped
        end
      
        desc "Manufacturer matching ID or name", {
          notes: <<-NOTE
            You can request a manufacturer by either their name or their ID
          NOTE
        }
        params do
          requires :id, type: String, desc: 'Manufacturer id or slug'
        end
        get ':id', serializer: ManufacturerV2ShowSerializer, protected: false do 
          if params[:id].match(/\A\d*\z/).present?
            manufacturer = Manufacturer.find(params[:id])
          else
            manufacturer = Manufacturer.fuzzy_name_find(params[:id])
          end
          unless manufacturer.present?
            msg = "Unable to find manufacturer with name or id: #{params[:id]}"
            raise ActiveRecord::RecordNotFound, msg
          end
          manufacturer
        end
      end

    end
  end
end