import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
//import java.util.ArrayList;
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
            connection = DriverManager.getConnection(url, user, password);
            connection.setAutoCommit(false);
            System.out.println("Database opened successfully");
            return true;
        } catch (Exception e) {
            System.out.println("Database failed to open successfully");
        }
        return false;
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        try {
            connection.commit();
            connection.close();
            connection = null;
            return true;
        } catch (Exception e) {
            System.out.println("Database failed to close successfully");
        }
        return false;
    }

    // A method that, given a country, returns the list of elections in that
    // country, in descending order of years, and the cabinets that have formed
    // after that election
    // and before the next election of the same type.
    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        PreparedStatment prep = null;
        ResultSet res = null;
        try {
            // Find Country id
            Integer country_id = -1;
            String country_id_query = "SELECT id from country where name=?";
            prep = connection.prepareStatement(country_id_query);
            prep.setString(1, countryName);
            res = prep.executeQuery();

            while (res.next())
                country_id = res.getInt("id");
            res.close();
            prep.close();

            if (country_id < 0)
                return null;

            String select_ids = "election.id as election_id cabinet.id as cabinet_id";
            String inner_join = "FROM cabinet INNER JOIN election ON cabinet.election_id=election.id";
            String query = "SELECT " + select_ids + " " + inner_join
                    + " WHERE country_id=? ORDER BY election.e_date DESC";
            prep = connection.prepareStatement(query);
            prep.setInt(1, country_id);
            res = prep.executeQuery();

            List<Integer> elections = new List<Integer>();
            List<Integer> cabinets = new List<Integer>();
            while (res.next()) {
                elections.add(res.getInt("election_id"));
                cabinets.add(res.getInt("cabinet_id"));
            }
            res.close();
            prep.close();
            return new ElectionCabinetResult(elections, cabinets);

        } catch (Exception e) {
            System.out.println("electionSequence failed");
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
        PreparedStatment prep = null;
        ResultSet res = null;
        try {
            // Find Politician Comment and Description
            String comment_and_description = null;
            String politician_query = "SELECT description, comment FROM politician_president WHERE id=?";
            prep = connection.prepareStatement(politician_query);
            prep.setInt(1, politicianName);
            res = prep.executeQuery();

            while (res.next())
                comment_and_description = res.getString("comment") + res.getString("description");
            res.close();
            prep.close();
            if (comment_and_description == null)
                return null;

            String compare_comment_and_description = null;
            String all_politician_query = "SELECT id, description, comment FROM politician_president";
            prep = connection.prepareStatement(all_politician_query);
            res = prep.executeQuery();

            List<Integer> similarPoliticians = new List<Integer>();
            while (res.next()) {
                compare_comment_and_description = res.getString("comment") + res.getString("description");
                if (similarity(comment_and_description, compare_comment_and_description) > threshold) {
                    similarPoliticians.add(res.getInt("id"));
                }
            }
            res.close();
            prep.close();
            return similarPoliticians;
        } catch (Exception e) {
            System.out.println("electionSequence failed");
        }
        return null;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
    }

}
