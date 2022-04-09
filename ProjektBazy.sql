CREATE TABLE komisja (
    				 id_komisji INTEGER NOT NULL PRIMARY KEY,
				 haslo TEXT NOT NULL
);
CREATE TABLE wybory (
    nr_wyborow                   INTEGER NOT NULL PRIMARY KEY,
    nazwa			 			TEXT,
    stanowisko                   TEXT,
    liczba_posad                 INTEGER,
    termin_zglaszania            DATE,
    start_glosowania   		 DATE,
    koniec_glosowania            DATE,
    opublikowane		 BOOLEAN,
    id_komisji  	 	 INTEGER REFERENCES komisja NOT NULL
);

CREATE TABLE kandydat (
    nr_indeksu_k          	 INTEGER NOT NULL PRIMARY KEY,
    nr_wyborow 			 INTEGER REFERENCES wybory NOT NULL, 
    stanowisko          	 TEXT,
    liczba_glosow		 INTEGER NOT NULL DEFAULT 0,
    imie                	 TEXT,
    nazwisko            	 TEXT   	 	 
);
CREATE TABLE glos (
    nr_glosu                     SERIAL PRIMARY KEY,
    nr_indeksu_w           	 INTEGER  NOT NULL,
    nr_indeksu_k		 INTEGER  NOT NULL
);
CREATE TABLE wyborca (
    nr_indeksu_w                 INTEGER NOT NULL PRIMARY KEY,
    czy_glosowal                 BOOLEAN,
    imie			 TEXT,
    nazwisko			 TEXT,
    nr_indeksu_k          	 INTEGER REFERENCES glos,
    id_komisji  	 	 INTEGER REFERENCES komisja NOT NULL
);

INSERT INTO komisja(id_komisji,haslo)
			VALUES (1, 'password');

INSERT INTO wyborca(nr_indeksu_w, czy_glosowal, id_komisji, imie, nazwisko)
			VALUES (1, 'FALSE', 1, 'Jan', 'Fasola');

INSERT INTO wyborca(nr_indeksu_w, czy_glosowal, id_komisji, imie, nazwisko)
			VALUES (2, 'FALSE', 1, 'Karol', 'Nowak');

INSERT INTO wyborca(nr_indeksu_w, czy_glosowal, id_komisji, imie, nazwisko)
			VALUES (3, 'FALSE', 1, 'Piotr', 'Filecki');

INSERT INTO wybory(nr_wyborow, nazwa, stanowisko, liczba_posad, termin_zglaszania, start_glosowania, koniec_glosowania, opublikowane, id_komisji) 
		VALUES (10, 'Na prezesa', 'Prezes', 1, '2021-06-30', '2021-06-23', '2021-07-14', 'FALSE', 1);


CREATE OR REPLACE FUNCTION logowanie(id INTEGER, password TEXT)
RETURNS BOOLEAN
AS $$
BEGIN
	IF NOT EXISTS (SELECT * FROM komisja WHERE komisja.id_komisji = id)
			THEN RAISE EXCEPTION 'Nie ma takiej komisji.';
	ELSIF NOT EXISTS (SELECT * FROM komisja WHERE komisja.id_komisji = id AND komisja.haslo = password)
			THEN RAISE EXCEPTION 'Bledne haslo.';
	ELSE
			RETURN TRUE;
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION logowanie(id INTEGER)
RETURNS BOOLEAN
AS $$
BEGIN
	IF NOT EXISTS (SELECT * FROM wyborca WHERE wyborca.nr_indeksu_w = id)
			THEN RAISE EXCEPTION 'Nie ma takiego wyborcy.';
	ELSE 
			RETURN TRUE;
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION nowe_wybory(id INTEGER,id_wyborow INTEGER, nazwa TEXT, stanowisko TEXT, liczba_posad INTEGER,
 termin_zglaszania DATE, start_glosowania DATE, koniec_glosowania DATE)
 RETURNS TEXT
AS $$
BEGIN
	IF NOT EXISTS (SELECT * FROM komisja WHERE komisja.id_komisji = id)
			THEN RAISE EXCEPTION 'Nie ma takiej komisji.';
	ELSIF EXISTS (SELECT * FROM wybory WHERE wybory.nr_wyborow = id_wyborow)
			THEN RAISE EXCEPTION 'Już są wybory o takim numerze.';
	ELSIF termin_zglaszania > koniec_glosowania
			THEN RAISE EXCEPTION 'Blednie podano daty.';
	ELSIF start_glosowania > koniec_glosowania
			THEN RAISE EXCEPTION 'Blednie podano daty.';
	ELSE 
		INSERT INTO wybory(nr_wyborow, nazwa, stanowisko, liczba_posad, termin_zglaszania,
start_glosowania, koniec_glosowania, opublikowane, id_komisji) 
		VALUES (id_wyborow, nazwa, stanowisko, liczba_posad, termin_zglaszania, start_glosowania, koniec_glosowania, 'FALSE', id);
	RETURN CONCAT('Nowe wybory ',nazwa,' dodane do bazy.');
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION nowy_wyborca(nr INTEGER, id_komisji INTEGER, imie TEXT, nazwisko TEXT)
RETURNS TEXT
AS $$
BEGIN
	IF EXISTS (SELECT * FROM wyborca WHERE wyborca.nr_indeksu_w = nr)
			THEN RAISE EXCEPTION 'Istnieje już taki wyborca.';
	ELSE 
			INSERT INTO wyborca(nr_indeksu_w, czy_glosowal, id_komisji, imie, nazwisko)
			VALUES (nr, 'FALSE', id_komisji, imie, nazwisko);
	RETURN CONCAT ('Nowy wyborca o numerze indeksu ',nr,' zostal dodany do bazy.');
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION nowy_kandydat(nr_kandydata INTEGER, imie TEXT, nazwisko TEXT, stanowisko TEXT, nr_wyb INTEGER)
 RETURNS TEXT
AS $$
BEGIN
	IF  NOT EXISTS (SELECT * FROM wybory WHERE wybory.nr_wyborow = nr_wyb)
			THEN RAISE EXCEPTION 'Nie ma takich wyborow.';
	ELSIF NOT EXISTS (SELECT * FROM wyborca WHERE wyborca.nr_indeksu_w = nr_kandydata)
			THEN RAISE EXCEPTION 'Kandydat musi byc wyborca.';
	ELSIF EXISTS (SELECT * FROM kandydat WHERE kandydat.nr_wyborow = nr_wyb AND kandydat.nr_indeksu_k = nr_kandydata)
			THEN RAISE EXCEPTION 'Ten kandydat jest juz zgloszony do tych wyborow.';
	ELSIF EXISTS (SELECT * FROM wybory WHERE wybory.nr_wyborow = nr_wyb AND CURRENT_DATE > wybory.termin_zglaszania)
			THEN RAISE EXCEPTION 'Czas na zglaszanie kandydatow do tych wyborow minal.';
	ELSE 
			INSERT INTO kandydat(nr_indeksu_k, nr_wyborow, stanowisko, imie, nazwisko)
			VALUES (nr_kandydata, nr_wyb, stanowisko, imie, nazwisko);
	RETURN CONCAT ('Nowy kandydat ',imie,' ',nazwisko,' zostal zgloszony do wyborow ',nr_wyb,' na stanowisko ',stanowisko,'.');
	END IF;
END;
$$
LANGUAGE plpgsql;   
	 
CREATE OR REPLACE FUNCTION nowy_glos(nr_wyb INTEGER, nr_kandydata INTEGER, nr_wyborcy INTEGER)
RETURNS TEXT
AS $$
BEGIN
	IF  NOT EXISTS (SELECT * FROM wybory WHERE wybory.nr_wyborow = nr_wyb)
			THEN RAISE EXCEPTION 'Nie ma takich wyborow.';
	ELSIF  NOT EXISTS (SELECT * FROM kandydat WHERE kandydat.nr_indeksu_k = nr_kandydata AND kandydat.nr_wyborow = nr_wyb)
			THEN RAISE EXCEPTION 'Ten kandydat nie bierze udzialu w tych wyborach.';
	ELSIF EXISTS (SELECT * FROM wyborca WHERE wyborca.nr_indeksu_w = nr_wyborcy AND wyborca.czy_glosowal = 'TRUE')
			THEN RAISE EXCEPTION 'Wskazany wyborca oddal juz glos.';
	ELSIF EXISTS (SELECT * FROM wybory WHERE wybory.nr_wyborow = nr_wyb AND CURRENT_DATE > wybory.koniec_glosowania)
			THEN RAISE EXCEPTION 'Czas na glosowanie w tych wyborach minal.';
	ELSIF EXISTS (SELECT * FROM wybory WHERE wybory.nr_wyborow = nr_wyb AND CURRENT_DATE < wybory.start_glosowania)
			THEN RAISE EXCEPTION 'Jeszcze nie mozna glosowac w tych wyborach.';
	ELSE 
			INSERT INTO glos(nr_indeksu_w, nr_indeksu_k)
			VALUES (nr_wyborcy, nr_kandydata);

			UPDATE kandydat
			SET liczba_glosow = liczba_glosow + 1
			WHERE kandydat.nr_indeksu_k = nr_kandydata;

			UPDATE wyborca
			SET czy_glosowal = 'TRUE'
			WHERE wyborca.nr_indeksu_w = nr_wyborcy;

	RETURN CONCAT ('Zaglosowano.');
	END IF;
END;
$$
LANGUAGE plpgsql; 

CREATE OR REPLACE FUNCTION opublikuj(nr_wyb INTEGER)
RETURNS TEXT
AS $$
BEGIN 
	IF EXISTS (SELECT * FROM wybory WHERE wybory.nr_wyborow = nr_wyb AND wybory.opublikowane = 'TRUE')
			THEN RAISE EXCEPTION 'Te wybory sa juz opublikowane.';
	ELSE 
			UPDATE wybory
			SET opublikowane = 'TRUE'
			WHERE wybory.nr_wyborow = nr_wyb;
	RETURN CONCAT ('Wybory o numerze ',nr_wyb,' zostaly opublikowane.');
	END IF;
END;
$$
LANGUAGE plpgsql; 

CREATE OR REPLACE FUNCTION ogladaj(nr_wyb INTEGER, l INTEGER) 
RETURNS TABLE (nr_wyborow INTEGER, imie TEXT, nazwisko TEXT, stanowisko TEXT, liczba_glosow INTEGER) 
AS $$
BEGIN
	IF NOT EXISTS (SELECT * FROM wybory WHERE wybory.nr_wyborow = nr_wyb AND wybory.opublikowane = 'TRUE')
			THEN RAISE EXCEPTION 'Te wybory nie sa jeszcze opublikowane.';
	ELSE

		RETURN QUERY
			SELECT wybory.nr_wyborow, kandydat.imie, kandydat.nazwisko, kandydat.stanowisko,
 kandydat.liczba_glosow FROM kandydat JOIN wybory ON kandydat.nr_wyborow = wybory.nr_wyborow WHERE kandydat.nr_wyborow = nr_wyb
ORDER BY kandydat.liczba_glosow DESC LIMIT l;
	END IF;		
	
END; 
$$
LANGUAGE plpgsql;