import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.*;
import java.util.ArrayList;
import java.util.Scanner;

public class ChessBoard extends JFrame implements Runnable {
    private JPanel gui;
    private ArrayList<JButton> buttons = new ArrayList<>();
    private JButton[][] chessBoardSquares = new JButton[8][8];
    private String[] labels;
    private File file = new File("/home/david/Documents/Github/Projects/Prolog/chess-game/file.txt");
    private static Dimension dimension = new Dimension(800, 800);
    private Color bgLight = new Color(222, 184, 135);
    private Color bgDark  = new Color(139, 69, 19);
    private Color clicked  = Color.lightGray;
    private boolean running;
    int buttonFrom = 0;
    int buttonTo = 0;
    String computerMove = "";
    String moveMade = "";
    String previousMove = "";
    boolean firstClick = true;
    int previousNum = 0;

    boolean whiteTurn = true;
    String lastFrom = "";
    String lastTo = "";

    // allow for castling..


    public ChessBoard() {
        for(int i = 0; i < 64; i++) buttons.add(new JButton());
        setTitle("Chess");
        setPreferredSize(dimension);
        setMinimumSize(dimension);
        setMaximumSize(dimension);
        setResizable(true);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        setSize(800,800);
        gui = new JPanel(new BorderLayout(1, 1));
        getContentPane().add(gui);
        pack();
        setVisible(true);
        setLabels();
        Thread t = new Thread(this);
        running = true;
        t.start();
    }

    @Override
    public void run() {
        while(running) {
            if(whiteTurn) {
                computerMove = readFile();
                if (!computerMove.equals(moveMade) && !computerMove.equals(previousMove) && !computerMove.equals("")) {
                    move(computerMove);
                    previousMove = computerMove;
                }
                whiteTurn = false;  // comment this line to do ai vs ai
            } else {
                String from = checkColRow(buttonFrom);
                String to = checkColRow(buttonTo);
                if(!from.equals(lastFrom) && !to.equals(lastTo)) {
                    moveMade = "'" + from + to + "'.";
//                    System.out.println("Move made = " + moveMade);
                    try {
                        writeFile(moveMade);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    move(moveMade);
                    previousMove = moveMade;
                    lastFrom = from;
                    lastTo = to;
                }
                whiteTurn = true;
            }
        }
        try {
            Thread.sleep(500);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    public void move(String move) {
//        System.out.println("Move in move() : " + move);
        int xf = (checkColRow(move.charAt(1)) - 1);
        int yf = ((checkColRow(move.charAt(2)) - 1) * 8);
        int xt = (checkColRow(move.charAt(3)) - 1);
        int yt = ((checkColRow(move.charAt(4)) - 1) * 8);
        int from = xf + yf;
        int to = xt + yt;
//        System.out.println("From: " + from + " To: " + to);
        if(from > 0 && to > 0) {
//            System.out.println("Swapped " + from + " to " + to);
            labels[to] = labels[from];
            labels[from] = "";
            revalidate();
            repaint();
        }
    }

    public String readFile() {
        String move = "";
        // Reading in the file
        Scanner scanner = null;
        try {
            scanner = new Scanner(file);
        } catch (FileNotFoundException e) {
            System.out.print("Error occurred when reading in the data from the file.\n");
            e.printStackTrace();
        }
        assert scanner != null;
        while (scanner.hasNextLine()) move = scanner.nextLine();
        return move;
    }

    public void writeFile(String move) throws IOException {
        BufferedWriter writer = new BufferedWriter(new FileWriter(file));
        try {
            writer.write(move);
        } catch (IOException e) {
            System.out.print("Error occurred when writing data to the file.\n");
            e.printStackTrace();
        }
        writer.close();
    }

    public int checkColRow(char c) {
        int num = 0;
        if (c == 'a' || c == '1')
            num = 1;
        if (c == 'b' || c == '2')
            num = 2;
        if (c == 'c' || c == '3')
            num = 3;
        if (c == 'd' || c == '4')
            num = 4;
        if (c == 'e' || c == '5')
            num = 5;
        if (c == 'f' || c == '6')
            num = 6;
        if (c == 'g' || c == '7')
            num = 7;
        if (c == 'h' || c == '8')
            num = 8;
        return num;
    }

    public String checkColRow(int num) {
        String row = "0"; // rank
        String col = "n"; // file
        int column = num % 8;

        if(column == 0)
            col = "a";
        if(column == 1)
            col = "b";
        if(column == 2)
            col = "c";
        if(column == 3)
            col = "d";
        if(column == 4)
            col = "e";
        if(column == 5)
            col = "f";
        if(column == 6)
            col = "g";
        if(column == 7)
            col = "h";

        if(num >= 56)
            row = "8";
        else if(num >= 48)
            row = "7";
        else if(num >= 40)
            row = "6";
        else if(num >= 32)
            row = "5";
        else if(num >= 24)
            row = "4";
        else if(num >= 16)
            row = "3";
        else if(num >= 8)
            row = "2";
        else if(num >= 0)
            row = "1";

        //System.out.println("inside checkColRow string = " + string + " row = " + row + " col = " + col + "\nColumn = " + column);
        return col + row;
    }

    public void setLabels() {
        labels = new String[]{
                "\u2656", "\u2658", "\u2657", "\u2655", "\u2654", "\u2657",
                "\u2658", "\u2656", "\u2659", "\u2659", "\u2659", "\u2659",
                "\u2659", "\u2659", "\u2659", "\u2659",
                "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                "\u265F", "\u265F", "\u265F", "\u265F", "\u265F", "\u265F",
                "\u265F", "\u265F", "\u265C", "\u265E", "\u265D", "\u265B",
                "\u265A", "\u265D", "\u265E", "\u265C",};
    }

    @Override
    public void paint(Graphics g) {
        super.paint(g);
        JPanel chessBoard = new JPanel(new GridLayout(0, 8));
        gui.add(chessBoard);

        gui.setDoubleBuffered(true);
        chessBoard.setDoubleBuffered(true);

        int c = 0;
        for (int i = 0; i < chessBoardSquares.length; i++) {
            for (int j = 0; j < chessBoardSquares[i].length; j++) {
                buttons.get(c).setFont(new Font("Ariel", Font.PLAIN, 56));
                buttons.get(c).setText(labels[c]);
                buttons.get(c).addActionListener(new ActionListener() {
                    @Override
                    public void actionPerformed(ActionEvent actionEvent) {
                        for (int i = 0; i < buttons.size(); i++) {
                            if (actionEvent.getSource() == buttons.get(i)) {
                                checkButtons(i);
                                buttons.get(i).setBackground(clicked);
                            }
                        }
                    }
                });
                if ((j % 2 == 1 && i % 2 == 1) || (j % 2 == 0 && i % 2 == 0)) buttons.get(c).setBackground(bgLight);
                else buttons.get(c).setBackground(bgDark);
                chessBoardSquares[j][i] = buttons.get(c);
                chessBoard.add(chessBoardSquares[j][i]);
                c++;
            }
        }
    }

    public void checkButtons(int num) {
        if(num != previousNum) {
            previousNum = num;
            if (firstClick) {
                buttonFrom = num;
                firstClick = false;
            } else {
                buttonTo = num;
                firstClick = true;
            }
        }
    }

    public static void main(String[] args) { new ChessBoard(); }
}