import json
import pandas as pd

def lambda_handler():
    try:
        #file_path = r'C:\Users\navodya hemachandra\Documents\terraform-aws\python\sample_request.json'

        # Read the contents of the JSON file
        with open('sample_request.json', 'r') as json_file:
            data = json.load(json_file)

        # Create a pandas DataFrame from the movies list
        df = pd.DataFrame(data['movies'])

        # Calculate the average rating of the movies
        average_rating = df['rating'].mean()

        # Find the director who directed the most number of movies
        director_with_most_movies = df['director'].value_counts().idxmax()

        # Create a new DataFrame of movies with rating above the average rating
        movies_above_average_rating = df[df['rating'] > average_rating]

        # Convert the filtered DataFrame to a list of dictionaries
        movies_above_average_list = movies_above_average_rating.to_dict(orient='records')

        # Create the response JSON
        response = {
            "average_rating": average_rating,
            "director_with_most_movies": director_with_most_movies,
            "movies_above_average_rating": movies_above_average_list
        }

        return response

    except Exception as e:
        # Return an error response if there's an issue with reading the file or processing the input
        return {
            "statusCode": 400,
            "body": json.dumps({"error": str(e)})
        }


if __name__ == "__main__":
    # Call the movie_rating_analysis function with the input JSON
    result = lambda_handler()

    # Print the result
    print(json.dumps(result, indent=2))