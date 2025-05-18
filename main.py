import sys
from pipeline_dimensional_data.flow import DimensionalDataFlow

# Function to parse user input for start and end dates
def parse_arguments():
    start = input('Input Start Date in the following format (YYYY-mm-dd): ')
    end = input('Input End Date in the following format (YYYY-mm-dd): ')
    return start, end

def main():
    args = parse_arguments()

    from datetime import datetime

    try:
        start_date = datetime.strptime(args[0], "%Y-%m-%d").date()
        end_date = datetime.strptime(args[1], "%Y-%m-%d").date()
    except ValueError as ve:
        print(f"Error: {ve}")
        sys.exit(1)

    if start_date > end_date:
        print("Error: start_date cannot be after end_date.")
        sys.exit(1)

    data_flow = DimensionalDataFlow()

    data_flow.exec(start_date=str(start_date), end_date=str(end_date))

if __name__ == "__main__":
    main()