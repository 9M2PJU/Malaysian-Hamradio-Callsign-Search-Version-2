from flask import Flask, request, jsonify, render_template
import subprocess
import shlex

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/api/callsign', methods=['GET'])
def callsign():
    callsign = request.args.get('callsign', '')
    
    # Call the shell script and get the output
    try:
        result = subprocess.run(
            shlex.split(f'./callsign.sh "{callsign}"'),
            capture_output=True,
            text=True,
            check=True
        )
        output = result.stdout.strip()
        
        # Print the shell script output for debugging
        print(f"Shell script output: {output}")

        if output.startswith("Formatted data:"):
            data = output.replace("Formatted data:\n", "").strip()
            fields = [field.strip() for field in data.split(',') if field.strip()]
            print(f"Parsed fields: {fields}")
            
            if len(fields) == 5:
                return jsonify({
                    'number': fields[0].strip(),
                    'name': fields[1].strip(),
                    'callsign': fields[2].strip(),
                    'assignment_number': fields[3].strip(),
                    'expiry_date': fields[4].strip()
                })
            else:
                return jsonify({'error': 'Incorrect data format'}), 400
        else:
            return jsonify({'error': 'Error retrieving data'}), 500

    except subprocess.CalledProcessError as e:
        print(f"Error executing shell script: {e}")
        return jsonify({'error': 'Error executing shell script'}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')

