import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;

//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try {
            connection = DriverManager.getConnection(url, username, password);
	    String parlgov = "SET search_path TO parlgov";
	    connection.prepareStatement(parlgov).execute();
            System.out.println("Database opened successfully");
            return true;
        } catch (Exception e) {
            e.printStackTrace();
	    return false;
        }
        
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        try {
            connection.close();
            connection = null;
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // A method that, given a country, returns the list of elections in that
    // country, in descending order of years, and the cabinets that have formed
    // after that election
    // and before the next election of the same type.
    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        try {
            // Find Country id
            Integer country_id = -1;
            String country_id_query = "SELECT id from country where name=?";
            PreparedStatement prep1 = connection.prepareStatement(country_id_query);
            prep1.setString(1, countryName);
            ResultSet res1 = prep1.executeQuery();

            while (res1.next())
                country_id = res1.getInt("id");
            res1.close();
            prep1.close();

            if (country_id < 0)
                return null;
	    System.out.println(country_id);
            String select_ids = "election.id AS election_id, cabinet.id AS cabinet_id";
            String inner_join = "FROM cabinet INNER JOIN election ON cabinet.election_id=election.id";
            String query = "SELECT " + select_ids + " " + inner_join
                    + " WHERE election.country_id=? ORDER BY election.e_date DESC";
            PreparedStatement prep2 = connection.prepareStatement(query);

            prep2.setInt(1, country_id);
            ResultSet res2 = prep2.executeQuery();

            List<Integer> elections = new ArrayList<>();
            List<Integer> cabinets = new ArrayList<>();
            while (res2.next()) {
                elections.add(res2.getInt("election_id"));
                cabinets.add(res2.getInt("cabinet_id"));
            }
            res2.close();
            prep2.close();
            return new ElectionCabinetResult(elections, cabinets);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // A method that, given a president, returns other presidents that have
    // similar comments and descriptions in the database. See section Similar
    // Politicians below
    // for details.
    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        try {
            // Find Politician Comment and Description
            String comment_and_description = null;
            String politician_query = "SELECT description, comment FROM politician_president WHERE id=?";
            PreparedStatement prep1 = connection.prepareStatement(politician_query);
            prep1.setInt(1, politicianName);
            ResultSet res1 = prep1.executeQuery();
            while (res1.next())
                comment_and_description = res1.getString("comment") + res1.getString("description");
            res1.close();
            prep1.close();
	    
            if (comment_and_description == null)
                return null;

	    //System.out.println(comment_and_description);

            String compare_comment_and_description = null;
            String all_politician_query = "SELECT id, description, comment FROM politician_president";
            PreparedStatement prep2 = connection.prepareStatement(all_politician_query);
            ResultSet res2 = prep2.executeQuery();

            List<Integer> similarPoliticians = new ArrayList<Integer>();
            while (res2.next()) {
                compare_comment_and_description = res2.getString("comment") + res2.getString("description");
                if (similarity(comment_and_description, compare_comment_and_description) > threshold) {
		    int pid = res2.getInt("id");
		    if (politicianName != pid)
                        similarPoliticians.add(pid);
                }
            }
            res2.close();
            prep2.close();
	    //System.out.println(compare_comment_and_description);
            return similarPoliticians;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        try {
            Assignment2 test = new Assignment2();
            System.out.println("instantiation completed");
            if (!test.connectDB("jdbc:postgresql://localhost:5432/csc343h-wonchanw", "wonchanw", "")) {
                System.out.println("connection failed");
		return;
            }
            // Test election sequence
            System.out.println("Test 1:");
            ElectionCabinetResult eResult = test.electionSequence("Canada");
	    if (eResult != null) {
		    for (int i = 0; i < eResult.elections.size(); ++i) {
		        System.out.println("Election: " + eResult.elections.get(i) + " Cabinet: " + eResult.cabinets.get(i));
		    }
	    }
            // Test findSimilarPoliticians
            System.out.println("Test 2:");
            List<Integer> politicians = test.findSimilarPoliticians(9, (float) 0.0);
            for (int i : politicians) {
                System.out.println(i);
            }

            test.disconnectDB();
        } catch (ClassNotFoundException e) {
            System.out.println("Instantiation Failed.");
        }
    }

}
