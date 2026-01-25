--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
-- SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: MessageStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."MessageStatus" AS ENUM (
    'Sent',
    'Read'
);


ALTER TYPE public."MessageStatus" OWNER TO postgres;

--
-- Name: UserStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."UserStatus" AS ENUM (
    'Active',
    'Inactive'
);


ALTER TYPE public."UserStatus" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- Name: app_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_users (
    id integer NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    username text NOT NULL,
    role text DEFAULT 'user'::text NOT NULL,
    country text,
    "nativeLang" text,
    "targetLang" text,
    level text DEFAULT 'A2'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status public."UserStatus" DEFAULT 'Inactive'::public."UserStatus" NOT NULL,
    avatar text,
    "userTag" text NOT NULL
);


ALTER TABLE public.app_users OWNER TO postgres;

--
-- Name: app_users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.app_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.app_users_id_seq OWNER TO postgres;

--
-- Name: app_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.app_users_id_seq OWNED BY public.app_users.id;


--
-- Name: archived_practice_tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.archived_practice_tasks (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    question text NOT NULL,
    options text[],
    correct text NOT NULL,
    explanation text NOT NULL,
    type text NOT NULL,
    answer text
);


ALTER TABLE public.archived_practice_tasks OWNER TO postgres;

--
-- Name: archived_practice_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.archived_practice_tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.archived_practice_tasks_id_seq OWNER TO postgres;

--
-- Name: archived_practice_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.archived_practice_tasks_id_seq OWNED BY public.archived_practice_tasks.id;


--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_messages (
    id integer NOT NULL,
    content text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status public."MessageStatus" DEFAULT 'Sent'::public."MessageStatus" NOT NULL,
    "senderId" integer NOT NULL,
    "roomId" integer NOT NULL
);


ALTER TABLE public.chat_messages OWNER TO postgres;

--
-- Name: chat_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_messages_id_seq OWNER TO postgres;

--
-- Name: chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_messages_id_seq OWNED BY public.chat_messages.id;


--
-- Name: chat_rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_rooms (
    id integer NOT NULL,
    theme text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP,
    "isOpen" boolean DEFAULT true NOT NULL,
    "maxUsers" integer DEFAULT 2 NOT NULL
);


ALTER TABLE public.chat_rooms OWNER TO postgres;

--
-- Name: chat_rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_rooms_id_seq OWNER TO postgres;

--
-- Name: chat_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_rooms_id_seq OWNED BY public.chat_rooms.id;


--
-- Name: correction_theory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.correction_theory (
    type text NOT NULL,
    title text NOT NULL,
    content text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.correction_theory OWNER TO postgres;

--
-- Name: corrections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.corrections (
    id integer NOT NULL,
    original text NOT NULL,
    corrected text NOT NULL,
    explanation text,
    "messageId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    type text NOT NULL
);


ALTER TABLE public.corrections OWNER TO postgres;

--
-- Name: corrections_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.corrections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.corrections_id_seq OWNER TO postgres;

--
-- Name: corrections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.corrections_id_seq OWNED BY public.corrections.id;


--
-- Name: daily_generated_tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.daily_generated_tasks (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    question text NOT NULL,
    options text[],
    correct text NOT NULL,
    explanation text NOT NULL,
    type text NOT NULL,
    answer text
);


ALTER TABLE public.daily_generated_tasks OWNER TO postgres;

--
-- Name: daily_generated_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.daily_generated_tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.daily_generated_tasks_id_seq OWNER TO postgres;

--
-- Name: daily_generated_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.daily_generated_tasks_id_seq OWNED BY public.daily_generated_tasks.id;


--
-- Name: daily_tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.daily_tasks (
    id integer NOT NULL,
    title text NOT NULL,
    content text NOT NULL,
    type text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    completed boolean DEFAULT false NOT NULL,
    "userId" integer NOT NULL
);


ALTER TABLE public.daily_tasks OWNER TO postgres;

--
-- Name: daily_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.daily_tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.daily_tasks_id_seq OWNER TO postgres;

--
-- Name: daily_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.daily_tasks_id_seq OWNED BY public.daily_tasks.id;


--
-- Name: room_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.room_users (
    "userId" integer NOT NULL,
    "roomId" integer NOT NULL
);


ALTER TABLE public.room_users OWNER TO postgres;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id integer NOT NULL,
    token text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "userId" integer NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sessions_id_seq OWNER TO postgres;

--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: user_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_progress (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    score integer NOT NULL,
    total integer NOT NULL
);


ALTER TABLE public.user_progress OWNER TO postgres;

--
-- Name: user_progress_archive; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_progress_archive (
    id integer NOT NULL,
    "userProgressId" integer NOT NULL,
    "archivedTaskId" integer NOT NULL
);


ALTER TABLE public.user_progress_archive OWNER TO postgres;

--
-- Name: user_progress_archive_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_progress_archive_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_progress_archive_id_seq OWNER TO postgres;

--
-- Name: user_progress_archive_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_progress_archive_id_seq OWNED BY public.user_progress_archive.id;


--
-- Name: user_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_progress_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_progress_id_seq OWNER TO postgres;

--
-- Name: user_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_progress_id_seq OWNED BY public.user_progress.id;


--
-- Name: app_users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_users ALTER COLUMN id SET DEFAULT nextval('public.app_users_id_seq'::regclass);


--
-- Name: archived_practice_tasks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archived_practice_tasks ALTER COLUMN id SET DEFAULT nextval('public.archived_practice_tasks_id_seq'::regclass);


--
-- Name: chat_messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages ALTER COLUMN id SET DEFAULT nextval('public.chat_messages_id_seq'::regclass);


--
-- Name: chat_rooms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_rooms ALTER COLUMN id SET DEFAULT nextval('public.chat_rooms_id_seq'::regclass);


--
-- Name: corrections id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.corrections ALTER COLUMN id SET DEFAULT nextval('public.corrections_id_seq'::regclass);


--
-- Name: daily_generated_tasks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daily_generated_tasks ALTER COLUMN id SET DEFAULT nextval('public.daily_generated_tasks_id_seq'::regclass);


--
-- Name: daily_tasks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daily_tasks ALTER COLUMN id SET DEFAULT nextval('public.daily_tasks_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: user_progress id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_progress ALTER COLUMN id SET DEFAULT nextval('public.user_progress_id_seq'::regclass);


--
-- Name: user_progress_archive id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_progress_archive ALTER COLUMN id SET DEFAULT nextval('public.user_progress_archive_id_seq'::regclass);


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
317c62ef-8eab-4387-aedb-73191793af7c	0a98b2b84dc10e04265f2cc0552479e22b727186a916bbe7047a5cfb084ecce4	2025-05-02 03:51:39.616851+03	20250418091004_init	\N	\N	2025-05-02 03:51:39.588881+03	1
fe038708-7517-4b34-925d-4c17ea976bd0	17d2485e5102eeaae089c520cfbcac1c478139373ca989b951a234d2f8e3ffed	2025-05-02 03:51:39.652011+03	20250501225632_fix_enum_defaults	\N	\N	2025-05-02 03:51:39.617362+03	1
9230bf15-ec41-4520-a702-86380e8848e8	591631837d1cd58ffc5fe642ee3ef1b058d7311047da1532a85ad3f4c7f09ba5	2025-06-25 19:21:49.053385+03	20250625162147_add_archive_support	\N	\N	2025-06-25 19:21:49.01038+03	1
82b49012-f2ba-4756-b8a6-5ccbc509d2aa	22d164027c8d7c613fa10d90e59ce842851723f4dfa452a3fff0e83434780678	2025-05-02 03:57:49.180837+03	20250502005747_make_updated_at_nullable_default	\N	\N	2025-05-02 03:57:49.177332+03	1
77de2380-4d3e-4c6e-92bf-38d747be81f8	78d07699931ea770ed3b664a599f6e627000928af0c27a78a84a1c32de27c491	2025-05-10 01:47:24.282297+03	20250509224723_your_migration_name	\N	\N	2025-05-10 01:47:24.192161+03	1
858652b8-a096-4a8d-8207-f8cc813dd43b	f9b6edd7a9936b5c2236f8901bdcb63c85b9f88e82a92d883e8caa7e95392502	2025-05-14 00:17:18.401799+03	20250513211716_add_corrections_and_progress	\N	\N	2025-05-14 00:17:18.301684+03	1
7dbc2349-45ed-484f-81b4-321030b46621	7af42317a5f3e2af6b9badcb8ba7908bc3ee24cb3e75c81df2b41b273ca553eb	2025-06-14 23:27:06.438824+03	20250614202705_add_user_tag	\N	\N	2025-06-14 23:27:06.403231+03	1
57c27785-edb1-4046-b2a6-efbdfce4c88a	d25e3f1eb3c337b1d7dbd865ffa39e76e491daca0c6067c95b67d4bb247d3767	2025-06-14 23:42:19.537535+03	20250614204217_add_user_tag1	\N	\N	2025-06-14 23:42:19.534528+03	1
1f39c436-fe29-4554-b565-5f6320cee16a	1166d3df67a8c3efb991aa95d3bc5e81e8c0a0143b7391518afe636f6e480323	2025-06-19 17:01:10.523007+03	20250619140108_add_is_open_max_users	\N	\N	2025-06-19 17:01:10.447225+03	1
265de7af-bd4a-403f-8399-86d96f1b8b76	ecc592c5b59d0125dffaca54cefaca29948a54ef288923201915e9c5bbbb984f	2025-06-19 23:31:06.764299+03	20250619203105_add_cascade_to_room_users	\N	\N	2025-06-19 23:31:06.614796+03	1
46c57268-3bc0-4ee1-a730-07075e9790fe	72412ce1186954ca53c20fe2ec970464f589544d57de37b67d59d4ac7cc46c77	2025-06-22 14:12:04.618403+03	20250622111203_add_correction_type_and_theory	\N	\N	2025-06-22 14:12:04.513271+03	1
ef30e6af-6c21-409a-be99-b0d2a8cd235f	3654334194c1bca94daf6d5a85c7cac2524f505c28ccbaf54d6d6db7083f9c49	2025-06-23 15:44:49.886231+03	20250623124449_add_user_progress	\N	\N	2025-06-23 15:44:49.851582+03	1
67d1a7d5-9ad8-4b60-ad19-53e94c7c1449	3f09015a8abfe2544adcd7e99a5bb59efad474790804fa24bb6c4a55ea7c31dc	2025-06-23 16:55:06.21618+03	20250623135504_daily_generated_tasks	\N	\N	2025-06-23 16:55:06.153608+03	1
420f1df5-826f-4b89-bbf1-4004d0a7195e	c10c704acf216c11f72dc21320c8e49fc32b5600bdff6a2a826862906a9d347d	2025-06-24 16:52:23.033896+03	20250624135221_daily_generated_tasks_add_anwer	\N	\N	2025-06-24 16:52:23.009353+03	1
\.


--
-- Data for Name: app_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_users (id, email, password, username, role, country, "nativeLang", "targetLang", level, "createdAt", status, avatar, "userTag") FROM stdin;
1	alice@example.com	$2b$10$BgUR3kyoARKm2IpGbkn8Q.JyBcEgXK6bZ3aloLA7rFUR33yq2bEiq	Alice	user	Ukraine	uk	en	A2	2025-05-02 00:53:12.221	Inactive	\N	alice_1111
2	bob@example.com	$2b$10$klrsG0sfKPh2j9IsqNanBO7wVmKXg0OZVAB3ViKQgXg34LxBewGOa	Bob	user	Ukraine	uk	en	A2	2025-05-02 00:53:37.051	Inactive	\N	bob_2222
3	adam@example.com	$2b$10$eR/kuIW5UUajp6fl4wvMzOioDS4Cct7dtKw0TiDSdKoCJ/4C28Rkq	adam	user	Польща	uk	en	A2	2025-06-19 20:20:01.598	Inactive	\N	adam_8722
\.


--
-- Data for Name: archived_practice_tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.archived_practice_tasks (id, "userId", date, question, options, correct, explanation, type, answer) FROM stdin;
1	1	2025-06-24 21:27:02.162	I _____ to the cinema last night.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	go
2	1	2025-06-24 21:27:02.165	She is _____ doctor.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'doctor' starts with a consonant sound.	article	the
3	1	2025-06-24 21:27:02.167	I _____ my keys at home this morning.	{forget,forgets,forgot,forgotten}	forgot	The correct answer is 'forgot' because it is the past simple form of the verb 'forget'.	tense	forgot
4	1	2025-06-24 21:27:02.169	She _____ to the gym three times a week.	{go,goes,went,gone}	goes	The correct answer is 'goes' because it is the present simple form of the verb 'go'.	tense	gone
5	1	2025-06-24 21:27:02.171	I have _____ finished my homework.	{already,just,yet,never}	just	The correct answer is 'just' because it indicates a recent action that is connected to the present moment.	adverb	just
6	1	2025-06-25 22:44:59.535	I ___ to the cinema last night.	{go,went,goes,going}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
7	1	2025-06-25 22:44:59.54	She is ___ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because it is used to specify a particular student in the class.	article	no article
8	1	2025-06-25 22:44:59.542	I ___ to the gym three times a week.	{go,going,goes,went}	go	The correct answer is 'go' because it is the present simple form of the verb 'go'.	tense	goes
9	1	2025-06-25 22:44:59.545	I have ___ seen that movie before.	{never,ever,already,yet}	never	The correct answer is 'never' because it is used to indicate that the action of seeing the movie has not occurred at any time in the past.	adverb	ever
10	2	2025-06-25 22:55:11.05	I _______ to the beach yesterday.	{go,goes,went,gone}	went	The correct answer is 'went' because 'yesterday' indicates a past action, so the past simple tense 'went' should be used.	tense	go
11	2	2025-06-25 22:55:11.053	She has _____ beautiful cat.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'beautiful' starts with a consonant sound, so the indefinite article 'a' should be used.	article	the
12	2	2025-06-25 22:55:11.055	They _____ to the party if they finish work on time.	{"will go",goes,went,gone}	will go	The correct answer is 'will go' because it is a future possibility, so the future simple 'will' should be used.	tense	went
13	2	2025-06-25 22:55:11.057	I _____ a book when you called me.	{read,"am reading","was reading","will read"}	was reading	The correct answer is 'was reading' because the action was already in progress when another action happened, so the past continuous tense 'was reading' should be used.	tense	was reading
14	2	2025-06-25 22:55:12.465	She is _____ student in the class.	{good,better,best,"the best"}	the best	The correct answer is 'the best' because it refers to a superlative form, so 'the best' should be used to indicate the highest level of comparison.	comparatives	best
15	1	2025-06-25 22:44:59.535	I ___ to the cinema last night.	{go,went,goes,going}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
16	1	2025-06-25 22:44:59.54	She is ___ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because it is used to specify a particular student in the class.	article	no article
17	1	2025-06-25 22:44:59.542	I ___ to the gym three times a week.	{go,going,goes,went}	go	The correct answer is 'go' because it is the present simple form of the verb 'go'.	tense	goes
18	1	2025-06-25 22:44:59.545	I have ___ seen that movie before.	{never,ever,already,yet}	never	The correct answer is 'never' because it is used to indicate that the action of seeing the movie has not occurred at any time in the past.	adverb	ever
19	1	2025-06-25 22:44:59.535	I ___ to the cinema last night.	{go,went,goes,going}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
20	1	2025-06-25 22:44:59.54	She is ___ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because it is used to specify a particular student in the class.	article	no article
21	1	2025-06-25 22:44:59.542	I ___ to the gym three times a week.	{go,going,goes,went}	go	The correct answer is 'go' because it is the present simple form of the verb 'go'.	tense	goes
22	1	2025-06-25 22:44:59.545	I have ___ seen that movie before.	{never,ever,already,yet}	never	The correct answer is 'never' because it is used to indicate that the action of seeing the movie has not occurred at any time in the past.	adverb	ever
23	3	2025-06-25 22:58:34.009	I _______ to the cinema last night.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
24	3	2025-06-25 22:58:34.012	She is _______ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because we use the definite article 'the' before a superlative adjective.	article	the
25	3	2025-06-25 22:58:34.014	I _______ to the gym three times a week.	{go,goes,went,gone}	go	The correct answer is 'go' because it is the present simple form of the verb 'go'.	tense	went
26	3	2025-06-25 22:58:34.016	She _______ her homework when the phone rang.	{finish,finishes,finished,finishing}	finished	The correct answer is 'finished' because it is the past simple form of the verb 'finish'.	tense	finishes
27	3	2025-06-25 22:58:34.017	I have _______ brother and two sisters.	{a,an,the,"no article"}	a	The correct answer is 'a' because we use the indefinite article 'a' before a singular countable noun.	article	the
28	3	2025-06-25 22:58:34.009	I _______ to the cinema last night.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
30	3	2025-06-25 22:58:34.012	She is _______ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because we use the definite article 'the' before a superlative adjective.	article	the
31	3	2025-06-25 22:58:34.014	I _______ to the gym three times a week.	{go,goes,went,gone}	go	The correct answer is 'go' because it is the present simple form of the verb 'go'.	tense	went
29	1	2025-06-25 22:44:59.535	I ___ to the cinema last night.	{go,went,goes,going}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
32	3	2025-06-25 22:58:34.016	She _______ her homework when the phone rang.	{finish,finishes,finished,finishing}	finished	The correct answer is 'finished' because it is the past simple form of the verb 'finish'.	tense	finishes
34	3	2025-06-25 22:58:34.017	I have _______ brother and two sisters.	{a,an,the,"no article"}	a	The correct answer is 'a' because we use the indefinite article 'a' before a singular countable noun.	article	the
33	1	2025-06-25 22:44:59.54	She is ___ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because it is used to specify a particular student in the class.	article	no article
35	1	2025-06-25 22:44:59.542	I ___ to the gym three times a week.	{go,going,goes,went}	go	The correct answer is 'go' because it is the present simple form of the verb 'go'.	tense	goes
36	1	2025-06-25 22:44:59.545	I have ___ seen that movie before.	{never,ever,already,yet}	never	The correct answer is 'never' because it is used to indicate that the action of seeing the movie has not occurred at any time in the past.	adverb	ever
37	3	2025-06-25 22:58:34.009	I _______ to the cinema last night.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
38	3	2025-06-25 22:58:34.012	She is _______ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because we use the definite article 'the' before a superlative adjective.	article	the
39	3	2025-06-25 22:58:34.014	I _______ to the gym three times a week.	{go,goes,went,gone}	go	The correct answer is 'go' because it is the present simple form of the verb 'go'.	tense	went
40	3	2025-06-25 22:58:34.016	She _______ her homework when the phone rang.	{finish,finishes,finished,finishing}	finished	The correct answer is 'finished' because it is the past simple form of the verb 'finish'.	tense	finishes
41	3	2025-06-25 22:58:34.017	I have _______ brother and two sisters.	{a,an,the,"no article"}	a	The correct answer is 'a' because we use the indefinite article 'a' before a singular countable noun.	article	the
42	1	2025-06-25 22:44:59.535	I ___ to the cinema last night.	{go,went,goes,going}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
43	1	2025-06-25 22:44:59.54	She is ___ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because it is used to specify a particular student in the class.	article	no article
44	1	2025-06-25 22:44:59.542	I ___ to the gym three times a week.	{go,going,goes,went}	go	The correct answer is 'go' because it is the present simple form of the verb 'go'.	tense	goes
45	1	2025-06-25 22:44:59.545	I have ___ seen that movie before.	{never,ever,already,yet}	never	The correct answer is 'never' because it is used to indicate that the action of seeing the movie has not occurred at any time in the past.	adverb	ever
46	1	2025-06-25 22:44:59.535	I ___ to the cinema last night.	{go,went,goes,going}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
47	1	2025-06-25 22:44:59.54	She is ___ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because it is used to specify a particular student in the class.	article	no article
48	1	2025-06-25 22:44:59.542	I ___ to the gym three times a week.	{go,going,goes,went}	go	The correct answer is 'go' because it is the present simple form of the verb 'go'.	tense	goes
49	1	2025-06-25 22:44:59.545	I have ___ seen that movie before.	{never,ever,already,yet}	never	The correct answer is 'never' because it is used to indicate that the action of seeing the movie has not occurred at any time in the past.	adverb	ever
50	3	2025-06-25 22:58:34.009	I _______ to the cinema last night.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
51	3	2025-06-25 22:58:34.012	She is _______ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because we use the definite article 'the' before a superlative adjective.	article	the
52	3	2025-06-25 22:58:34.014	I _______ to the gym three times a week.	{go,goes,went,gone}	go	The correct answer is 'go' because it is the present simple form of the verb 'go'.	tense	went
53	3	2025-06-25 22:58:34.016	She _______ her homework when the phone rang.	{finish,finishes,finished,finishing}	finished	The correct answer is 'finished' because it is the past simple form of the verb 'finish'.	tense	finishes
54	3	2025-06-25 22:58:34.017	I have _______ brother and two sisters.	{a,an,the,"no article"}	a	The correct answer is 'a' because we use the indefinite article 'a' before a singular countable noun.	article	the
55	1	2025-06-25 22:44:59.535	I ___ to the cinema last night.	{go,went,goes,going}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
56	1	2025-06-25 22:44:59.54	She is ___ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because it is used to specify a particular student in the class.	article	no article
57	1	2025-06-25 22:44:59.542	I ___ to the gym three times a week.	{go,going,goes,went}	go	The correct answer is 'go' because it is the present simple form of the verb 'go'.	tense	goes
58	1	2025-06-25 22:44:59.545	I have ___ seen that movie before.	{never,ever,already,yet}	never	The correct answer is 'never' because it is used to indicate that the action of seeing the movie has not occurred at any time in the past.	adverb	ever
59	1	2025-06-25 23:29:44.805	I _______ to the store yesterday.	{go,goes,went,gone}	went	The correct answer is 'went' because we use the past simple tense to talk about actions that happened in the past.	tense	gone
60	1	2025-06-25 23:29:44.808	She is _______ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because we use the definite article 'the' before a superlative adjective.	article	no article
61	1	2025-06-25 23:29:44.81	My brother _______ to the gym three times a week.	{go,goes,going,gone}	goes	The correct answer is 'goes' because we use the present simple tense for habitual actions.	tense	going
62	1	2025-06-25 23:29:44.813	I have _______ finished my homework.	{just,already,yet,still}	just	The correct answer is 'just' because we use it with the present perfect tense to indicate a recent action.	tense	already
63	1	2025-06-25 23:29:44.815	She is _______ intelligent girl.	{a,an,the,"no article"}	an	The correct answer is 'an' because we use the indefinite article 'an' before a word starting with a vowel sound.	article	the
64	1	2025-06-25 23:30:16.732	I _____ my homework before I went to bed.	{did,do,does,doing}	did	The correct answer is 'did' because it is the past simple form of the verb 'do' used to talk about actions that happened in the past.	tense	does
65	1	2025-06-25 23:30:16.734	She _____ English and French fluently.	{speak,speaks,spoken,speaking}	speaks	The correct answer is 'speaks' because it is the correct form of the verb 'speak' for third person singular subjects.	verb agreement	speaks
66	1	2025-06-25 23:30:16.736	I have _____ seen that movie before.	{never,always,sometimes,often}	never	The correct answer is 'never' because it is used to indicate that something has not happened at any time before now.	adverb	often
67	1	2025-06-25 23:30:16.727	I _____ to the store yesterday.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past tense form of the verb 'go'.	tense	went
68	1	2025-06-25 23:30:16.73	She is _____ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because it is used before a superlative adjective to show that something has the highest degree of a quality.	article	no article
69	1	2025-06-25 23:36:06.648	I ________ to the library yesterday.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	gone
70	1	2025-06-25 23:36:06.653	She is ________ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because it is used before a superlative adjective to indicate that something or someone is the best, worst, most, least, etc., in a group.	article	no article
71	1	2025-06-25 23:36:06.663	My brother ________ to Spain last summer.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
72	1	2025-06-25 23:36:06.667	I have ________ finished my homework.	{just,already,yet,still}	just	The correct answer is 'just' because it is used to indicate a very recent action in the present perfect tense.	adverbs	yet
73	1	2025-06-25 23:36:06.671	She ________ her keys at home this morning.	{forget,forgets,forgot,forgotten}	forgot	The correct answer is 'forgot' because it is the past simple form of the verb 'forget'.	tense	forgot
74	1	2025-06-25 23:36:06.648	I ________ to the library yesterday.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	gone
75	1	2025-06-25 23:36:06.653	She is ________ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because it is used before a superlative adjective to indicate that something or someone is the best, worst, most, least, etc., in a group.	article	no article
76	1	2025-06-25 23:36:06.663	My brother ________ to Spain last summer.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
77	1	2025-06-25 23:36:06.667	I have ________ finished my homework.	{just,already,yet,still}	just	The correct answer is 'just' because it is used to indicate a very recent action in the present perfect tense.	adverbs	yet
78	1	2025-06-25 23:36:06.671	She ________ her keys at home this morning.	{forget,forgets,forgot,forgotten}	forgot	The correct answer is 'forgot' because it is the past simple form of the verb 'forget'.	tense	forgot
79	1	2025-06-25 23:41:32.071	I ________ to the gym every day.	{go,goes,going,goed}	go	The correct answer is 'go' because we use the base form of the verb for present simple tense in the first person singular (I).	tense	going
80	1	2025-06-25 23:41:32.074	She has ________ brother and two sisters.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'brother' is a countable singular noun and requires an indefinite article.	article	an
81	1	2025-06-25 23:41:32.077	They ________ to the beach when it started raining.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go' which is used to talk about actions completed in the past.	tense	went
82	1	2025-06-25 23:41:32.082	She is ________ student in the class.	{"most intelligent","more intelligent",intelligent,"the most intelligent"}	the most intelligent	The correct answer is 'the most intelligent' because it is the superlative form of the adjective 'intelligent' used to compare one person to all others in the class.	comparatives	the most intelligent
83	1	2025-06-25 23:41:32.079	I have ________ finished my homework.	{already,just,still,never}	already	The correct answer is 'already' because it is used to show that an action is completed before a certain time or event in the present perfect tense.	tense	still
84	1	2025-06-25 23:49:20.622	I _______ to the store yesterday.	{go,goes,went,gone}	went	The correct answer is 'went' because we use the past simple tense to talk about actions that happened in the past.	tense	go
85	1	2025-06-25 23:49:20.628	My sister _____ to the gym every day.	{go,goes,going,gone}	goes	The correct answer is 'goes' because we use the base form of the verb 'go' with the third person singular subjects (he, she, it).	verb agreement	goes
86	1	2025-06-25 23:49:20.633	I need _____ help with my homework.	{many,some,any,a}	some	The correct answer is 'some' because we use 'some' for requesting or offering something in positive sentences.	quantifiers	any
87	1	2025-06-25 23:49:20.625	She has _____ cat and two dogs.	{a,an,the,"no article"}	a	The correct answer is 'a' because we use the indefinite article 'a' for singular countable nouns when they are mentioned for the first time.	article	the
88	1	2025-06-25 23:49:20.63	They _____ to the beach last summer.	{go,goes,went,gone}	went	The correct answer is 'went' because we use the past simple tense to talk about actions that happened in the past.	tense	goes
89	1	2025-06-25 23:49:20.628	My sister _____ to the gym every day.	{go,goes,going,gone}	goes	The correct answer is 'goes' because we use the base form of the verb 'go' with the third person singular subjects (he, she, it).	verb agreement	goes
90	1	2025-06-25 23:49:20.633	I need _____ help with my homework.	{many,some,any,a}	some	The correct answer is 'some' because we use 'some' for requesting or offering something in positive sentences.	quantifiers	any
91	1	2025-06-25 23:49:20.625	She has _____ cat and two dogs.	{a,an,the,"no article"}	a	The correct answer is 'a' because we use the indefinite article 'a' for singular countable nouns when they are mentioned for the first time.	article	the
92	1	2025-06-25 23:49:20.63	They _____ to the beach last summer.	{go,goes,went,gone}	went	The correct answer is 'went' because we use the past simple tense to talk about actions that happened in the past.	tense	goes
93	1	2025-06-25 23:56:59.586	She is _______ nurse.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'nurse' starts with a consonant sound.	article	the
94	1	2025-06-25 23:56:59.588	I _______ to the beach if it doesn't rain.	{"will go",goes,went,going}	will go	The correct answer is 'will go' because it expresses a future possibility.	modal verb	going
95	1	2025-06-25 23:56:59.59	They _______ their homework before dinner.	{finish,finishes,finished,finishing}	finish	The correct answer is 'finish' because it is the base form of the verb used with 'they'.	subject-verb agreement	finished
96	1	2025-06-25 23:56:59.583	I _______ to the store yesterday.	{go,goes,going,went}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	go
97	1	2025-06-25 23:57:01.009	I have _______ been to Paris.	{never,ever,always,sometimes}	never	The correct answer is 'never' because it is used to indicate that the action has not happened at any time in the past.	adverbs of frequency	ever
98	1	2025-06-26 00:00:35.857	I _______ to the library yesterday.	{go,goes,went,gone}	went	The correct answer is 'went' because we use the past simple tense for actions that happened in the past.	tense	goes
99	1	2025-06-26 00:00:35.861	She is _______ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because we use the definite article 'the' when talking about a specific noun, in this case, 'student'.	article	no article
100	1	2025-06-26 00:00:35.864	They _______ to the beach last summer.	{go,goes,went,gone}	went	The correct answer is 'went' because we use the past simple tense for actions that happened in the past.	tense	went
101	1	2025-06-26 00:00:35.866	I have _______ finished my homework.	{already,yet,just,still}	just	The correct answer is 'just' because we use 'just' to indicate a completed action very recently.	adverb	still
102	1	2025-06-26 00:00:35.869	She _______ her keys at home this morning.	{forget,forgets,forgot,forgotten}	forgot	The correct answer is 'forgot' because we use the past simple tense for actions that happened in the past.	tense	forgot
103	3	2025-06-25 22:58:34.009	I _______ to the cinema last night.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
104	3	2025-06-25 22:58:34.012	She is _______ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because we use the definite article 'the' before a superlative adjective.	article	the
105	3	2025-06-25 22:58:34.014	I _______ to the gym three times a week.	{go,goes,went,gone}	go	The correct answer is 'go' because it is the present simple form of the verb 'go'.	tense	went
106	3	2025-06-25 22:58:34.016	She _______ her homework when the phone rang.	{finish,finishes,finished,finishing}	finished	The correct answer is 'finished' because it is the past simple form of the verb 'finish'.	tense	finishes
107	3	2025-06-25 22:58:34.017	I have _______ brother and two sisters.	{a,an,the,"no article"}	a	The correct answer is 'a' because we use the indefinite article 'a' before a singular countable noun.	article	the
108	1	2025-06-26 01:07:00.87	I ___ to the gym every day.	{go,going,goes,gone}	go	The correct answer is 'go' because 'go' is the base form of the verb used with 'I'.	verb tense	go
109	1	2025-06-26 01:07:00.874	She is ___ doctor.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'doctor' starts with a consonant sound.	article	the
110	1	2025-06-26 01:07:00.876	They ___ to the beach last weekend.	{go,going,goes,went}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	verb tense	going
111	1	2025-06-26 01:07:03.413	I have ___ finished my homework.	{already,just,yet,still}	just	The correct answer is 'just' because it indicates a recently completed action.	adverb placement	still
112	1	2025-06-26 01:07:03.416	She ___ to the party if she wasn't feeling sick.	{go,"would go",went,going}	would go	The correct answer is 'would go' because it is the correct form for a hypothetical situation in the past.	conditional sentences	went
113	1	2025-06-26 01:07:00.87	I ___ to the gym every day.	{go,going,goes,gone}	go	The correct answer is 'go' because 'go' is the base form of the verb used with 'I'.	verb tense	go
114	1	2025-06-26 01:07:00.874	She is ___ doctor.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'doctor' starts with a consonant sound.	article	the
115	1	2025-06-26 01:07:00.876	They ___ to the beach last weekend.	{go,going,goes,went}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	verb tense	going
116	1	2025-06-26 01:07:03.413	I have ___ finished my homework.	{already,just,yet,still}	just	The correct answer is 'just' because it indicates a recently completed action.	adverb placement	still
117	1	2025-06-26 01:07:03.416	She ___ to the party if she wasn't feeling sick.	{go,"would go",went,going}	would go	The correct answer is 'would go' because it is the correct form for a hypothetical situation in the past.	conditional sentences	went
118	1	2025-06-26 01:07:00.87	I ___ to the gym every day.	{go,going,goes,gone}	go	The correct answer is 'go' because 'go' is the base form of the verb used with 'I'.	verb tense	go
119	1	2025-06-26 01:07:00.874	She is ___ doctor.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'doctor' starts with a consonant sound.	article	the
120	1	2025-06-26 01:07:00.876	They ___ to the beach last weekend.	{go,going,goes,went}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	verb tense	going
121	1	2025-06-26 01:07:03.413	I have ___ finished my homework.	{already,just,yet,still}	just	The correct answer is 'just' because it indicates a recently completed action.	adverb placement	still
122	1	2025-06-26 01:07:03.416	She ___ to the party if she wasn't feeling sick.	{go,"would go",went,going}	would go	The correct answer is 'would go' because it is the correct form for a hypothetical situation in the past.	conditional sentences	went
123	1	2025-06-26 01:07:00.87	I ___ to the gym every day.	{go,going,goes,gone}	go	The correct answer is 'go' because 'go' is the base form of the verb used with 'I'.	verb tense	go
124	1	2025-06-26 01:07:00.874	She is ___ doctor.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'doctor' starts with a consonant sound.	article	the
125	1	2025-06-26 01:07:00.876	They ___ to the beach last weekend.	{go,going,goes,went}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	verb tense	going
126	1	2025-06-26 01:07:03.413	I have ___ finished my homework.	{already,just,yet,still}	just	The correct answer is 'just' because it indicates a recently completed action.	adverb placement	still
127	1	2025-06-26 01:07:03.416	She ___ to the party if she wasn't feeling sick.	{go,"would go",went,going}	would go	The correct answer is 'would go' because it is the correct form for a hypothetical situation in the past.	conditional sentences	went
128	1	2025-06-26 01:07:00.87	I ___ to the gym every day.	{go,going,goes,gone}	go	The correct answer is 'go' because 'go' is the base form of the verb used with 'I'.	verb tense	go
129	1	2025-06-26 01:07:00.874	She is ___ doctor.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'doctor' starts with a consonant sound.	article	the
130	1	2025-06-26 01:07:00.876	They ___ to the beach last weekend.	{go,going,goes,went}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	verb tense	going
131	1	2025-06-26 01:07:03.413	I have ___ finished my homework.	{already,just,yet,still}	just	The correct answer is 'just' because it indicates a recently completed action.	adverb placement	still
132	1	2025-06-26 01:07:03.416	She ___ to the party if she wasn't feeling sick.	{go,"would go",went,going}	would go	The correct answer is 'would go' because it is the correct form for a hypothetical situation in the past.	conditional sentences	went
133	1	2025-06-26 01:07:00.87	I ___ to the gym every day.	{go,going,goes,gone}	go	The correct answer is 'go' because 'go' is the base form of the verb used with 'I'.	verb tense	go
134	1	2025-06-26 01:07:00.874	She is ___ doctor.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'doctor' starts with a consonant sound.	article	the
135	1	2025-06-26 01:07:00.876	They ___ to the beach last weekend.	{go,going,goes,went}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	verb tense	going
136	1	2025-06-26 01:07:03.413	I have ___ finished my homework.	{already,just,yet,still}	just	The correct answer is 'just' because it indicates a recently completed action.	adverb placement	still
137	1	2025-06-26 01:07:03.416	She ___ to the party if she wasn't feeling sick.	{go,"would go",went,going}	would go	The correct answer is 'would go' because it is the correct form for a hypothetical situation in the past.	conditional sentences	went
138	1	2025-06-26 12:37:05.9	She has _____ beautiful cat.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'cat' starts with a consonant sound.	article	the
139	1	2025-06-26 12:37:05.902	They _____ to the party if they finish work on time.	{"will go",going,goes,went}	will go	The correct answer is 'will go' because it is the future simple form used for predictions.	tense	went
140	1	2025-06-26 12:37:05.903	I am _____ tired to go out tonight.	{so,such,too,very}	too	The correct answer is 'too' because it is used to show an excessive degree.	adverb	such
141	1	2025-06-26 12:37:05.896	I _____ to the store yesterday.	{go,going,goes,went}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	go
142	1	2025-06-26 12:37:05.905	She _____ to the gym three times a week.	{go,going,goes,went}	goes	The correct answer is 'goes' because it is the present simple form used for habits or routines.	tense	going
143	1	2025-06-26 12:41:03.547	I ___ to the park yesterday.	{go,goes,went,gone}	went	The correct answer is 'went' because we use the past simple tense for actions that happened in the past.	tense	went
144	1	2025-06-26 12:41:03.55	She wants ___ buy a new car.	{to,at,in,on}	to	The correct answer is 'to' because 'want' is followed by the infinitive form of the verb.	infinitive	to
145	1	2025-06-26 12:41:03.553	They ___ a lot of friends when they lived in Spain.	{have,has,had,having}	had	The correct answer is 'had' because we use the past simple tense to talk about past actions or states.	tense	has
146	1	2025-06-26 12:41:03.555	I need ___ help with my homework.	{some,any,a,many}	some	The correct answer is 'some' because it is used for unspecified or a limited quantity of something.	determiner	a
147	1	2025-06-26 12:41:03.557	She ___ to the gym three times a week.	{go,goes,going,gone}	goes	The correct answer is 'goes' because it is the third person singular form of the verb 'go' in the present simple tense.	verb form	going
148	1	2025-06-26 12:41:50.794	I ___ to the movies last night.	{go,went,goes,going}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	go
149	1	2025-06-26 12:41:50.796	She wants ___ buy a new car.	{to,at,in,for}	to	The correct answer is 'to' because after the verb 'wants' we use the infinitive form of the verb.	infinitive	in
150	1	2025-06-26 12:41:52.146	I have ___ apples in the fridge.	{a,an,some,any}	some	The correct answer is 'some' because it is used for unspecified quantity of countable nouns in positive sentences.	articles	some
151	1	2025-06-26 12:41:52.148	They ___ playing football when it started raining.	{was,is,are,were}	were	The correct answer is 'were' because it agrees with the subject 'they' in the past continuous tense.	tense	is
152	1	2025-06-26 12:41:52.15	I always ___ my homework on time.	{finish,finishes,finished,finishing}	finish	The correct answer is 'finish' because it is the base form of the verb used with adverbs of frequency like 'always'.	verb form	finish
153	1	2025-06-26 12:48:55.318	I _____ to the park yesterday.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	goes
154	1	2025-06-26 12:48:55.322	She has _____ cat.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'cat' starts with a consonant sound.	article	the
155	1	2025-06-26 12:48:55.324	They _____ to the beach every summer.	{go,goes,went,gone}	go	The correct answer is 'go' because it is the base form of the verb used for habitual actions.	tense	goes
156	1	2025-06-26 12:48:55.326	I need _____ help with my homework.	{many,some,any,much}	some	The correct answer is 'some' because it is used with uncountable nouns like 'help'.	quantifiers	some
157	1	2025-06-26 12:51:41.717	I _______ to the store yesterday.	{go,goes,went,gone}	went	The correct answer is 'went' because we use the past simple tense to talk about actions that happened in the past.	tense	go
158	1	2025-06-26 12:51:41.72	She is _____ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because we use the definite article 'the' before a superlative adjective like 'the best'.	article	the
159	1	2025-06-26 12:51:41.722	I _____ my keys at home this morning.	{forget,forgets,forgot,forgotten}	forgot	The correct answer is 'forgot' because we use the past simple tense to talk about actions that happened in the past.	tense	forgot
160	1	2025-06-26 12:51:41.723	She _____ to the gym every day.	{go,goes,going,gone}	goes	The correct answer is 'goes' because we use the base form of the verb 'go' with 'she' in the present simple tense.	tense	go
161	1	2025-06-26 12:51:41.725	I have _____ finished my homework.	{just,already,yet,never}	just	The correct answer is 'just' because we use 'just' to indicate a very recent action that is completed.	adverb	just
162	1	2025-06-26 12:57:02.499	I _______ to the library yesterday.	{go,went,goes,going}	went	The correct answer is 'went' because the sentence is in the past tense, and 'went' is the past form of the verb 'go'.	tense	went
163	1	2025-06-26 12:57:02.502	She is _______ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because it is used to refer to a specific student, in this case, the best one in the class.	article	no article
164	1	2025-06-26 12:57:02.504	I _______ my keys at home this morning.	{forget,forgets,forgot,forgetting}	forgot	The correct answer is 'forgot' because the sentence is in the past tense, and 'forgot' is the past form of the verb 'forget'.	tense	forgot
165	1	2025-06-26 12:57:04.284	My sister goes to the gym _______ day.	{every,each,all,some}	every	The correct answer is 'every' because it is used to show the frequency of an action that happens regularly.	frequency adverbs	each
166	1	2025-06-26 12:57:04.286	We have _______ bananas in the fridge.	{some,any,a,an}	some	The correct answer is 'some' because it is used for an unspecified quantity of countable or uncountable nouns.	quantifiers	a
167	1	2025-06-26 12:57:46.879	She is _______ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because it is used before a superlative adjective to show that something has the highest degree of a quality.	article	no article
168	1	2025-06-26 12:57:48.524	I like to play tennis _______ my brother prefers soccer.	{and,but,or,so}	but	The correct answer is 'but' because it shows a contrast between the speaker's preference and the brother's preference.	conjunction	or
169	1	2025-06-26 12:57:48.526	We _______ to the beach if the weather is nice.	{go,goes,"will go",gone}	will go	The correct answer is 'will go' because it is used to talk about a future event that is likely to happen.	future tense	goes
170	1	2025-06-26 12:57:48.528	She _______ her homework before dinner.	{finish,finishes,finished,finishing}	finishes	The correct answer is 'finishes' because the present simple tense is used to talk about habits or routines.	tense	finished
171	1	2025-06-26 12:57:46.876	I _______ to the library yesterday.	{go,goes,went,gone}	went	The correct answer is 'went' because 'yesterday' indicates a past time, so the past simple tense should be used.	tense	went
172	1	2025-06-26 13:07:02.421	I _______ to the beach yesterday.	{go,goes,went,gone}	went	The correct past form of the verb 'go' is 'went'.	tense	go
173	1	2025-06-26 13:07:02.424	She wants _______ apple from the store.	{a,an,the,some}	an	Use 'an' before words that begin with a vowel sound, like 'apple'.	article	the
174	1	2025-06-26 13:07:02.426	We have _______ English class on Mondays.	{an,a,the,some}	an	Use 'an' before words that begin with a vowel sound, like 'English'.	article	a
175	1	2025-06-26 13:07:02.428	They _______ to the park every weekend.	{go,goes,went,gone}	go	Use the base form of the verb 'go' with plural subjects like 'they'.	tense	gone
176	1	2025-06-26 13:07:02.43	I like _______ music.	{a,an,the,some}	the	Use 'the' when talking about specific things, like 'the music' you are referring to.	article	an
177	1	2025-06-26 13:07:02.421	I _______ to the beach yesterday.	{go,goes,went,gone}	went	The correct past form of the verb 'go' is 'went'.	tense	go
178	1	2025-06-26 13:07:02.424	She wants _______ apple from the store.	{a,an,the,some}	an	Use 'an' before words that begin with a vowel sound, like 'apple'.	article	the
179	1	2025-06-26 13:07:02.426	We have _______ English class on Mondays.	{an,a,the,some}	an	Use 'an' before words that begin with a vowel sound, like 'English'.	article	a
180	1	2025-06-26 13:07:02.428	They _______ to the park every weekend.	{go,goes,went,gone}	go	Use the base form of the verb 'go' with plural subjects like 'they'.	tense	gone
181	1	2025-06-26 13:07:02.43	I like _______ music.	{a,an,the,some}	the	Use 'the' when talking about specific things, like 'the music' you are referring to.	article	an
\.


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_messages (id, content, "createdAt", status, "senderId", "roomId") FROM stdin;
12	Hey Bob! You mean "went", not "goed"	2025-05-02 04:00:11.305	Read	2	2
16	No worries. What animals did you saw?	2025-05-02 21:05:14.698	Read	2	2
21	Yes! I taked many pictures.	2025-05-10 14:44:21.978	Read	2	2
23	Really? We should go together next weekend!	2025-05-10 14:53:36.73	Read	2	2
15	Not yet, planning to watch.	2025-05-02 04:00:11.305	Read	2	3
19	hi	2025-05-10 01:01:53.243	Read	2	3
14	Have you seen the new movie?	2025-05-02 04:00:11.305	Read	1	3
18	hi	2025-05-10 01:01:46.337	Read	1	3
11	Hi Alice! Yesterday I goed to the zoo.	2025-05-02 04:00:11.305	Read	1	2
13	Oh right. I always forget that.	2025-05-02 04:00:11.305	Read	1	2
17	I saw lions, monkeys, and a elefant.	2025-05-09 23:57:41.777	Read	1	2
20	Wow, I love elephants. They is so smart.	2025-05-10 14:03:53.31	Read	1	2
22	Send me some! Also, I was never at a zoo before.	2025-05-10 14:48:12.203	Read	1	2
24	That's sounds amazing. I will brang snacks.	2025-05-10 23:39:26.447	Read	1	2
25	Deal! And I will bring the tickets	2025-05-11 11:44:14.966	Read	1	2
26	Can't wait! Hope weather be nice	2025-05-13 23:14:01.487	Read	1	2
27	Let's also invite Sam if he free.	2025-05-16 20:06:01.922	Read	1	2
28	Great idea! He loves animals too.	2025-05-16 20:06:13.803	Read	1	2
29	Okay, I will message him today.	2025-05-27 18:56:47.686	Read	2	2
30	Please check.	2025-06-09 13:10:41.865	Read	2	3
31	Okay, checked.	2025-06-09 13:11:39.831	Read	1	3
32	checked	2025-06-09 13:13:43.854	Read	2	3
33	+	2025-06-09 13:15:05.826	Read	1	3
34	+	2025-06-09 13:15:25.979	Read	1	3
35	+	2025-06-09 13:15:26.388	Read	1	3
36	+	2025-06-09 13:15:26.695	Read	1	3
37	+	2025-06-09 13:15:26.99	Read	1	3
38	+	2025-06-09 13:15:27.292	Read	1	3
39	+	2025-06-09 13:15:27.573	Read	1	3
40	+	2025-06-09 13:15:27.856	Read	1	3
41	+	2025-06-09 13:15:28.119	Read	1	3
42	+	2025-06-09 13:15:28.385	Read	1	3
43	+	2025-06-09 13:15:28.758	Read	1	3
44	+	2025-06-09 13:15:29.231	Read	1	3
45	+	2025-06-09 13:15:29.511	Read	1	3
46	+	2025-06-09 13:15:29.774	Read	1	3
47	+	2025-06-09 13:15:30.062	Read	1	3
48	+	2025-06-09 13:15:30.343	Read	1	3
49	+	2025-06-09 13:15:30.626	Read	1	3
50	+	2025-06-09 13:15:30.892	Read	1	3
51	+	2025-06-09 13:15:31.158	Read	1	3
52	-	2025-06-10 21:04:34.248	Read	2	3
53	-	2025-06-10 21:04:56.942	Read	2	3
54	It seems like your message is empty. Could you please provide the sentence you'd like me to improve?	2025-06-10 21:05:08.776	Read	2	3
55	-	2025-06-10 21:05:20.246	Read	2	3
56	/	2025-06-13 20:07:06.495	Read	2	3
57	*	2025-06-13 20:09:41.885	Read	2	3
58	/	2025-06-13 20:12:33.23	Read	1	3
59	*	2025-06-13 20:30:44.243	Read	1	3
60	/	2025-06-13 20:31:14.153	Read	1	3
61	*	2025-06-13 20:32:12.2	Read	2	3
62	1	2025-06-13 20:33:16.92	Read	2	3
63	2	2025-06-13 20:33:21.211	Read	2	3
66	555	2025-06-13 20:43:24.628	Read	2	3
64	Let's plan the details in the evening.	2025-06-13 20:42:13.98	Read	2	2
65	Sure! See you later!	2025-06-13 20:42:21.428	Read	2	2
67	55	2025-06-15 09:07:41.091	Read	1	3
68	5	2025-06-15 09:10:54.005	Read	1	3
69	5	2025-06-15 09:12:32.426	Read	1	3
70	1	2025-06-15 09:20:20.151	Read	1	3
71	2	2025-06-15 09:20:38.126	Read	2	3
72	3	2025-06-15 09:22:32.871	Read	2	3
73	4	2025-06-15 09:27:01.197	Read	2	3
74	3	2025-06-15 11:41:55.908	Read	2	3
75	2	2025-06-15 11:57:58.995	Read	2	3
76	3	2025-06-15 11:58:32.025	Read	2	3
77	3	2025-06-15 12:11:36.924	Read	2	3
78	1	2025-06-15 12:44:25.799	Read	2	3
79	1	2025-06-19 09:30:21.678	Read	1	3
80	22	2025-06-19 09:30:49.366	Read	1	3
81	1	2025-06-19 09:32:47.56	Read	1	3
82	2	2025-06-19 09:36:57.489	Read	1	3
83	2	2025-06-19 09:56:12.051	Read	1	3
84	1	2025-06-19 09:56:27.453	Read	1	3
85	2	2025-06-19 09:56:52.385	Read	2	3
86	2	2025-06-22 10:55:24.99	Read	1	3
\.


--
-- Data for Name: chat_rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_rooms (id, theme, "createdAt", "updatedAt", "isOpen", "maxUsers") FROM stdin;
2	Business & Entrepreneurship	2025-05-02 03:58:17.742	2025-05-02 03:58:17.742	t	2
3	Movies & Series	2025-05-02 03:58:17.742	2025-05-02 03:58:17.742	t	2
4	books	2025-06-19 14:17:45.679	2025-06-19 14:17:45.679	t	2
11	1_3	2025-06-20 19:09:36.333	2025-06-20 19:09:36.333	f	2
\.


--
-- Data for Name: correction_theory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.correction_theory (type, title, content, "createdAt") FROM stdin;
infinitive	Title: Understanding the Infinitive in English	Description: In English grammar, the infinitive is the base form of a verb, usually preceded by 'to' (e.g., to eat, to sleep). It is used to express purpose, intention, or to show what someone wants or needs to do. The infinitive can also be used without 'to' after modal verbs like 'can,' 'should,' or 'must' (e.g., I can swim, she must go). Understanding how to use infinitives correctly is essential for forming sentences in English.	2025-06-22 15:08:50.724
present simple	Title: Present Simple Tense	Description: The present simple tense is used to talk about regular actions, routines, facts, and general truths. In the present simple, we add 's' or 'es' to the base form of the verb for he, she, it, singular nouns, and when the subject is singular. For example, "She works in an office." In negative sentences, we use 'do not' or 'does not' before the base form of the verb. For example, "He does not like coffee." Questions in the present simple are formed by starting the sentence with 'do' or 'does'. For example, "Do you speak English?" I hope this helps clarify the concept of the present simple tense for you! Let me know if you have any more questions.	2025-06-22 15:08:52.679
tense	Title: Understanding Tense in English Grammar	Description: Tense in English grammar refers to the time when an action takes place – past, present, or future. There are three main tenses: past, present, and future. Each tense can be further divided into simple, continuous (progressive), perfect, and perfect continuous forms. By understanding and using tenses correctly, you can accurately convey when an action happened or will happen in a sentence. Practice using different tenses to improve your English language skills.	2025-06-22 14:41:34.005
article	Title: Understanding Articles in English Grammar	Description: In English grammar, articles are words that define a noun as specific or unspecific. There are three articles in English: "the," "a," and "an." "The" is used to refer to a specific noun that both the speaker and listener are familiar with. "A" and "an" are used to refer to a non-specific noun. "A" is used before words that begin with a consonant sound, while "an" is used before words that begin with a vowel sound. Mastering the use of articles is important for clear and accurate communication in English.	2025-06-22 14:41:34.01
determiner	Title: Understanding Determiners in English Grammar	Description: Determiners are words that come before a noun to give more information about it. They help specify which noun is being referred to. Common determiners include articles (a, an, the), demonstratives (this, that, these, those), possessives (my, your, his, her, its, our, their), and quantifiers (some, any, many, few). Determiners are essential in constructing clear and precise sentences in English, as they indicate the quantity or specificity of the noun. Mastering the use of determiners can greatly enhance your ability to communicate effectively in English.	2025-06-22 15:29:50.608
verb agreement	Title: Verb Agreement	Description: Verb agreement in English refers to the need for a verb to match the subject of a sentence in terms of number (singular or plural). For example, if the subject is singular (e.g., "he" or "she"), the verb should also be singular (e.g., "is" or "eats"). Conversely, if the subject is plural (e.g., "they" or "we"), the verb should be plural (e.g., "are" or "eat"). Making sure that the verb agrees with the subject helps to ensure that the sentence is grammatically correct and clear.	2025-06-22 15:47:18.393
adverb	Title: Understanding Adverbs in English	Description: Adverbs are words that modify or describe verbs, adjectives, or other adverbs in a sentence. They provide information on how, when, where, or to what extent an action is done. For example, in the sentence "She sings beautifully," the adverb "beautifully" describes how she sings. Adverbs can be formed by adding "-ly" to adjectives (e.g., quick → quickly) or can be irregular (e.g., well, fast). Adverbs are essential in providing additional details and enhancing the meaning of a sentence.	2025-06-22 14:41:34.015
adverbs	Title: Understanding Adverbs in English Grammar	Description: Adverbs are words that modify verbs, adjectives, or other adverbs by providing more information about how, when, where, or to what extent an action is done. For example, in the sentence "She sings beautifully," the adverb "beautifully" describes how she sings. Adverbs can be formed by adding "-ly" to adjectives (e.g., quick → quickly) or by using irregular forms (e.g., good → well). Adverbs are important for adding detail and clarity to sentences.	2025-06-22 16:23:41.766
conditional	Title: Understanding Conditionals in English Grammar	Description: Conditionals are sentences that express a condition and its result. There are four main types of conditionals in English: zero conditional, first conditional, second conditional, and third conditional. Each type is used to talk about different situations and their possible outcomes. Conditionals often use the words "if" to introduce the condition and "will," "would," "could," or "might" to express the result. Understanding conditionals is important for expressing hypothetical situations and making predictions in English.	2025-06-22 16:26:47.949
preposition	Title: Understanding Prepositions in English	Description: Prepositions are words that show the relationship between a noun or pronoun and other words in a sentence. They often indicate location, direction, time, or the relationship between two things. Common prepositions include "in," "on," "at," "by," "for," and "with." For example, in the sentence "The book is on the table," "on" is the preposition showing the relationship between the book and the table. Understanding prepositions is essential for forming correct and meaningful sentences in English.	2025-06-22 14:47:16.834
conditional sentences	Title: Conditional Sentences	Description: Conditional sentences are used to express a condition and its result. There are four types of conditional sentences: zero, first, second, and third conditional. In zero conditional, the condition is always true. First conditional is used for real possibilities in the future. Second conditional is used for unreal or unlikely situations in the present or future. Third conditional is used to talk about unreal situations in the past. Each type has a specific structure using different verb tenses and modal verbs.	2025-06-22 16:39:24.637
subject-verb agreement	Title: Subject-Verb Agreement	Description: Subject-verb agreement means that the subject of a sentence must agree with the verb in terms of number (singular or plural). For example, if the subject is singular, the verb should also be singular, and if the subject is plural, the verb should be plural. This agreement helps to ensure that sentences are grammatically correct and easy to understand. Paying attention to subject-verb agreement can help you communicate your ideas clearly in English.	2025-06-22 16:43:15.869
modal verb	Title: Modal Verbs in English Grammar	Description: Modal verbs are a type of auxiliary verb that express possibility, necessity, ability, or permission in a sentence. Common modal verbs include "can," "could," "may," "might," "must," "shall," "should," "will," and "would." They are always followed by a base verb (infinitive) without "to" and do not change form based on the subject. Modal verbs are used to add nuance to a sentence, such as indicating likelihood ("She might be coming later"), obligation ("You must finish your homework"), or politeness ("Could you please pass the salt?"). I hope this explanation helps you understand the concept of modal verbs in English grammar!	2025-06-22 16:44:11.801
verb form	Title: Verb Form in English Grammar	Description: The verb form in English refers to the different ways a verb can change to show tense, aspect, mood, voice, and agreement with the subject. Verbs can have different forms such as base form (infinitive), present tense, past tense, present participle (-ing form), and past participle. For example, the verb "to be" has forms like "am" (present tense), "was" (past tense), and "been" (past participle). Understanding verb forms is essential for constructing grammatically correct sentences in English.	2025-06-22 16:44:12.875
future tense	Title: Future Tense	Description: The future tense is used to talk about actions or events that will happen in the future. In English, we often form the future tense by using the auxiliary verb "will" followed by the base form of the main verb. For example, "I will go to the store tomorrow." We can also use "going to" to talk about future plans or intentions, like "She is going to study for her exam tonight." The future tense helps us express our future thoughts, predictions, and intentions clearly.	2025-06-23 13:19:31.391
quantifiers	Title: Understanding Quantifiers in English Grammar	Description: Quantifiers are words used before nouns to give information about the quantity or amount of something. They can be divided into two main categories: specific and nonspecific quantifiers. Specific quantifiers, such as "some," "many," and "a few," give a specific amount or number, while nonspecific quantifiers, like "much," "any," and "enough," give a more general sense of quantity. Understanding how to use quantifiers correctly is important for expressing quantities accurately in English sentences.	2025-06-23 14:22:04.098
modal verbs	Title: Understanding Modal Verbs in English	Description: Modal verbs are a special type of auxiliary verbs that express necessity, possibility, permission, or ability in a sentence. Some common modal verbs include "can," "could," "may," "might," "must," "shall," "should," "will," and "would." Modal verbs are always followed by the base form of a main verb (e.g., "I can swim"). They do not change form based on the subject and are used to add nuances to the meaning of a sentence. Understanding modal verbs is essential for expressing different levels of certainty, obligation, or ability in English sentences. Practice using modal verbs in various contexts to improve your fluency and accuracy in using them.	2025-06-24 16:34:54.666
comparison	Title: Comparison in English	Description: When we compare things in English, we use comparative and superlative forms of adjectives and adverbs. The comparative form is used to compare two things, while the superlative form is used to compare three or more things. To form the comparative, we usually add "-er" to short adjectives and use "more" before long adjectives. For the superlative, we add "-est" to short adjectives and use "most" before long adjectives. For adverbs, we usually add "-er" or "more" for the comparative and "-est" or "most" for the superlative. Practice using these forms to make comparisons in English.	2025-06-24 16:49:53.028
time	Title: Understanding Time in English Grammar	Description: In English grammar, time refers to when an action takes place. There are three main tenses to express time: past, present, and future. The past tense is used to talk about actions that have already happened, the present tense is used for actions happening now, and the future tense is used for actions that will happen later. Understanding the concept of time in English grammar helps you communicate effectively and accurately in different situations.	2025-06-24 16:56:36.355
gerund	Title: Understanding Gerunds in English Grammar	Description: A gerund is a verb form that ends in -ing and functions as a noun in a sentence. It is created by adding -ing to the base form of a verb (e.g., "swimming," "reading"). Gerunds can be used as subjects, objects, or complements in a sentence. For example, in the sentence "I enjoy swimming," "swimming" is a gerund that acts as the object of the verb "enjoy." Gerunds are versatile and can be used in various ways to convey actions, activities, or concepts in a sentence.	2025-06-24 17:00:10.03
frequency adverb	Title: Frequency Adverbs in English	Description: Frequency adverbs are words that indicate how often something happens. Common frequency adverbs include "always," "often," "sometimes," "rarely," and "never." These adverbs are usually placed before the main verb in a sentence. For example, "I always go to the gym on Mondays." Using frequency adverbs helps to provide more information about the regularity or occurrence of an action in a sentence. Practice using frequency adverbs to improve your English fluency and accuracy in describing routines or habits.	2025-06-24 21:58:38.878
comparatives	Title: Comparatives in English Grammar	Description: Comparatives are used to compare two things, showing the difference in degree between them. To form comparatives, add "-er" to short adjectives (e.g., "bigger") or use "more" before long adjectives (e.g., "more interesting"). When comparing two things, use "than" after the comparative form (e.g., "She is taller than him"). Remember to use comparatives when you want to show that one thing has more or less of a quality than another.	2025-06-25 22:55:12.463
adverbs of frequency	Title: Adverbs of Frequency	Description: Adverbs of frequency tell us how often something happens. Common adverbs of frequency include "always," "often," "sometimes," "rarely," and "never." They are usually placed before the main verb in a sentence. For example, in the sentence "I always go to the gym," "always" is the adverb of frequency. Adverbs of frequency help us to express how regular or irregular an action is in English sentences.	2025-06-25 23:57:01.007
verb tense	Title: Understanding Verb Tense	Description: Verb tense in English indicates the time at which an action takes place. There are three main tenses: past, present, and future. Each tense can be further divided into simple, continuous, perfect, and perfect continuous forms. It is important to use the correct tense to convey the timing of an action accurately in a sentence. Practice using different tenses to improve your English language skills.	2025-06-26 01:07:00.868
adverb placement	Title: Adverb Placement in English	Description: Adverbs are words that modify verbs, adjectives, or other adverbs to provide more information about how, when, where, or to what extent something is done. In English, adverbs can be placed in different positions in a sentence depending on the type of adverb and the context. Generally, adverbs can be placed before the main verb, after the verb (if the verb is not a modal or auxiliary verb), or at the beginning or end of a sentence for emphasis. It's important to pay attention to adverb placement to ensure clear and effective communication in English sentences.	2025-06-26 01:07:03.411
comparatives and superlatives	Title: Comparatives and Superlatives	Description: Comparatives are used to compare two things, while superlatives are used to compare three or more things. To form comparatives, add "-er" to short adjectives (e.g., "bigger") or use "more" before long adjectives (e.g., "more interesting"). For superlatives, add "-est" to short adjectives (e.g., "biggest") or use "most" before long adjectives (e.g., "most interesting"). Remember to use "than" after comparatives to complete the comparison (e.g., "She is taller than him"). I hope this helps clarify the concept of comparatives and superlatives for you! Let me know if you have any more questions.	2025-06-26 12:23:06.187
articles	Title: Understanding Articles in English	Description: Articles are small words (a, an, the) that come before nouns to give more information about them. "A" and "an" are indefinite articles used before singular nouns to talk about any one of that thing, while "the" is the definite article used before singular or plural nouns to talk about a specific thing known to both the speaker and the listener. It's important to remember when to use each article based on whether you're talking about something specific or something non-specific.	2025-06-26 12:41:52.144
verb to be	Title: Understanding the Verb "To Be"	Description: The verb "to be" is a fundamental verb in English that is used to describe states of being, identity, and existence. It can be conjugated into different forms depending on the subject of the sentence: "am" (I), "is" (he, she, it), "are" (you, we, they). For example, "I am happy," "She is a doctor," "We are students." It is also used to form the present continuous tense, such as "I am studying," indicating an action happening at the moment. Mastering the verb "to be" is essential for forming basic sentences in English.	2025-06-26 12:42:32.235
present perfect	Title: Present Perfect Tense	Description: The present perfect tense is used to talk about actions or events that happened at an unspecified time in the past, but have a connection to the present. It is formed by using the auxiliary verb "have" or "has" followed by the past participle of the main verb. For example, "I have visited Paris." This tense is often used to talk about experiences, achievements, or actions that have a relevance to the present moment. It is important to note that the present perfect tense is not used with specific time expressions like "yesterday" or "last week."	2025-06-26 12:42:33.476
frequency adverbs	Title: Frequency Adverbs in English	Description: Frequency adverbs are words that describe how often an action is done. Common frequency adverbs include "always," "often," "sometimes," "rarely," and "never." These adverbs are usually placed before the main verb in a sentence. For example, in the sentence "I always go to the gym on Mondays," "always" is the frequency adverb indicating that the action of going to the gym happens regularly. Understanding and using frequency adverbs helps to provide more detail and clarity in describing actions and routines.	2025-06-26 12:57:04.282
conjunction	Title: Conjunctions: Joining Words and Sentences	Description: Conjunctions are words that connect words, phrases, or clauses in a sentence. They help to show the relationship between different parts of a sentence. Common conjunctions include "and," "but," "or," "so," and "because." For example, in the sentence "I like to read books and watch movies," the conjunction "and" connects the two activities. Conjunctions are important for making sentences clear and coherent.	2025-06-26 12:57:48.523
\.


--
-- Data for Name: corrections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.corrections (id, original, corrected, explanation, "messageId", "createdAt", type) FROM stdin;
\.


--
-- Data for Name: daily_generated_tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daily_generated_tasks (id, "userId", date, question, options, correct, explanation, type, answer) FROM stdin;
1	1	2025-06-23 14:22:02.803	I ________ to the beach yesterday.	{go,went,goes,going}	went	The correct past form of 'go' is 'went'.	tense	\N
3	1	2025-06-23 14:22:02.812	We usually ________ dinner at 7 o'clock.	{have,has,having,had}	have	Use 'have' for plural subjects like 'we'.	verb agreement	\N
4	1	2025-06-23 14:22:02.814	He ________ to the gym three times a week.	{go,goes,going,went}	goes	Use the base form 'goes' with 'he', 'she', 'it' subjects in the present simple tense.	tense	\N
5	1	2025-06-23 14:22:04.1	I need ________ information about the project.	{many,much,"a lot",some}	some	Use 'some' for uncountable nouns like 'information'.	quantifiers	\N
49	2	2025-06-24 21:58:37.413	I _____ to the supermarket yesterday.	{go,goes,going,went}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	\N
6	2	2025-06-24 11:59:27.743	I _______ to the store yesterday.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	go
7	2	2025-06-24 11:59:27.745	She is _______ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because we use the definite article 'the' before a superlative adjective.	article	the
8	2	2025-06-24 11:59:27.747	She _______ a new car last week.	{buy,buys,bought,buying}	bought	The correct answer is 'bought' because it is the past simple form of the verb 'buy'.	tense	buying
9	2	2025-06-24 11:59:27.749	I have _______ finished my work.	{just,already,yet,still}	just	The correct answer is 'just' because it is used to indicate that an action was completed very recently.	adverb	still
43	1	2025-06-24 17:41:24.959	She _______ her keys at home yesterday.	{forget,forgets,forgot,forgotten}	forgot	The correct answer is 'forgot' because we use the simple past tense for actions that happened in the past.	tense	forgotten
34	3	2025-06-24 17:11:14.916	I _______ to the store yesterday.	{go,goes,went,gone}	went	The correct past tense form of 'go' is 'went'.	tense	goes
35	3	2025-06-24 17:11:14.92	She has _______ brother and two sisters.	{a,an,the,"no article"}	a	Use the indefinite article 'a' before a singular countable noun like 'brother'.	article	an
36	3	2025-06-24 17:11:14.923	I _______ watching TV when the phone rang.	{am,was,is,are}	was	Use the past continuous 'was watching' to describe an action that was interrupted by another action.	tense	is
39	1	2025-06-24 17:41:24.948	I _______ to the store yesterday.	{go,going,goes,went}	went	The correct answer is 'went' because we use the simple past tense to talk about actions that happened in the past.	tense	go
40	1	2025-06-24 17:41:24.952	She is _______ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because we use the definite article 'the' before a superlative adjective.	article	a
37	3	2025-06-24 17:11:14.925	They _______ to the beach last weekend.	{go,goes,went,gone}	went	The correct past tense form of 'go' is 'went'.	tense	went
42	1	2025-06-24 17:41:24.956	I have _______ finished my homework.	{already,just,still,yet}	just	The correct answer is 'just' because we use 'just' with the present perfect tense to indicate a recent action.	tense	still
41	1	2025-06-24 17:41:24.954	They _______ to the beach every summer.	{go,goes,going,went}	go	The correct answer is 'go' because we use the base form of the verb for habitual actions.	tense	goes
38	3	2025-06-24 17:11:14.927	I need _______ milk to make a cake.	{some,any,a,an}	some	Use 'some' for an unspecified quantity of a countable or uncountable noun.	determiner	some
50	2	2025-06-24 21:58:37.418	She is _____ doctor.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'doctor' starts with a consonant sound.	article	\N
51	2	2025-06-24 21:58:37.422	I _____ TV when the phone rang.	{watch,watches,"was watching",watched}	was watching	The correct answer is 'was watching' because it describes an action that was in progress when another action happened.	tense	\N
52	2	2025-06-24 21:58:37.425	She _____ to the gym three times a week.	{go,goes,going,went}	goes	The correct answer is 'goes' because it is the present simple form of the verb 'go'.	tense	\N
53	2	2025-06-24 21:58:38.88	I have _____ seen that movie before.	{never,always,sometimes,often}	never	The correct answer is 'never' because it is used to indicate that something has not happened at any time before now.	frequency adverb	\N
44	1	2025-06-24 21:27:02.162	I _____ to the cinema last night.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	go
45	1	2025-06-24 21:27:02.165	She is _____ doctor.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'doctor' starts with a consonant sound.	article	the
46	1	2025-06-24 21:27:02.167	I _____ my keys at home this morning.	{forget,forgets,forgot,forgotten}	forgot	The correct answer is 'forgot' because it is the past simple form of the verb 'forget'.	tense	forgot
47	1	2025-06-24 21:27:02.169	She _____ to the gym three times a week.	{go,goes,went,gone}	goes	The correct answer is 'goes' because it is the present simple form of the verb 'go'.	tense	gone
48	1	2025-06-24 21:27:02.171	I have _____ finished my homework.	{already,just,yet,never}	just	The correct answer is 'just' because it indicates a recent action that is connected to the present moment.	adverb	just
58	2	2025-06-25 22:55:11.05	I _______ to the beach yesterday.	{go,goes,went,gone}	went	The correct answer is 'went' because 'yesterday' indicates a past action, so the past simple tense 'went' should be used.	tense	go
59	2	2025-06-25 22:55:11.053	She has _____ beautiful cat.	{a,an,the,"no article"}	a	The correct answer is 'a' because 'beautiful' starts with a consonant sound, so the indefinite article 'a' should be used.	article	the
60	2	2025-06-25 22:55:11.055	They _____ to the party if they finish work on time.	{"will go",goes,went,gone}	will go	The correct answer is 'will go' because it is a future possibility, so the future simple 'will' should be used.	tense	went
61	2	2025-06-25 22:55:11.057	I _____ a book when you called me.	{read,"am reading","was reading","will read"}	was reading	The correct answer is 'was reading' because the action was already in progress when another action happened, so the past continuous tense 'was reading' should be used.	tense	was reading
62	2	2025-06-25 22:55:12.465	She is _____ student in the class.	{good,better,best,"the best"}	the best	The correct answer is 'the best' because it refers to a superlative form, so 'the best' should be used to indicate the highest level of comparison.	comparatives	best
63	3	2025-06-25 22:58:34.009	I _______ to the cinema last night.	{go,goes,went,gone}	went	The correct answer is 'went' because it is the past simple form of the verb 'go'.	tense	went
64	3	2025-06-25 22:58:34.012	She is _______ student in the class.	{a,an,the,"no article"}	the	The correct answer is 'the' because we use the definite article 'the' before a superlative adjective.	article	the
65	3	2025-06-25 22:58:34.014	I _______ to the gym three times a week.	{go,goes,went,gone}	go	The correct answer is 'go' because it is the present simple form of the verb 'go'.	tense	went
66	3	2025-06-25 22:58:34.016	She _______ her homework when the phone rang.	{finish,finishes,finished,finishing}	finished	The correct answer is 'finished' because it is the past simple form of the verb 'finish'.	tense	finishes
67	3	2025-06-25 22:58:34.017	I have _______ brother and two sisters.	{a,an,the,"no article"}	a	The correct answer is 'a' because we use the indefinite article 'a' before a singular countable noun.	article	the
178	1	2025-06-26 13:07:02.421	I _______ to the beach yesterday.	{go,goes,went,gone}	went	The correct past form of the verb 'go' is 'went'.	tense	go
179	1	2025-06-26 13:07:02.424	She wants _______ apple from the store.	{a,an,the,some}	an	Use 'an' before words that begin with a vowel sound, like 'apple'.	article	the
180	1	2025-06-26 13:07:02.426	We have _______ English class on Mondays.	{an,a,the,some}	an	Use 'an' before words that begin with a vowel sound, like 'English'.	article	a
181	1	2025-06-26 13:07:02.428	They _______ to the park every weekend.	{go,goes,went,gone}	go	Use the base form of the verb 'go' with plural subjects like 'they'.	tense	gone
182	1	2025-06-26 13:07:02.43	I like _______ music.	{a,an,the,some}	the	Use 'the' when talking about specific things, like 'the music' you are referring to.	article	an
\.


--
-- Data for Name: daily_tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daily_tasks (id, title, content, type, "createdAt", completed, "userId") FROM stdin;
\.


--
-- Data for Name: room_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.room_users ("userId", "roomId") FROM stdin;
1	2
2	2
1	3
2	3
1	4
3	11
1	11
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (id, token, "createdAt", "expiresAt", "userId") FROM stdin;
\.


--
-- Data for Name: user_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_progress (id, "userId", "createdAt", date, score, total) FROM stdin;
1	1	2025-06-24 18:16:47.362	2025-06-23 21:00:00	0	5
3	2	2025-06-25 22:55:45.572	2025-06-25 21:00:00	1	5
6	3	2025-06-25 23:06:39.484	2025-06-25 21:00:00	2	5
2	1	2025-06-25 22:53:34.2	2025-06-25 21:00:00	0	5
\.


--
-- Data for Name: user_progress_archive; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_progress_archive (id, "userProgressId", "archivedTaskId") FROM stdin;
1	2	9
2	2	8
3	2	7
4	2	6
5	3	14
6	3	13
7	3	12
8	3	11
9	3	10
10	2	18
11	2	17
12	2	16
13	2	15
14	2	22
15	2	21
16	2	20
17	2	19
18	6	27
19	6	26
20	6	25
21	6	24
22	6	23
23	2	36
24	6	34
25	2	35
26	2	33
27	2	29
28	6	32
29	6	31
30	6	30
31	6	28
32	6	41
33	6	40
34	6	39
35	6	38
36	6	37
37	2	45
38	2	44
39	2	43
40	2	42
41	2	49
42	2	48
43	2	47
44	2	46
45	6	54
46	6	53
47	6	52
48	6	51
49	6	50
50	2	58
51	2	57
52	2	56
53	2	55
54	2	63
55	2	62
56	2	61
57	2	60
58	2	59
59	2	68
60	2	67
61	2	66
62	2	65
63	2	64
64	2	73
65	2	72
66	2	71
67	2	70
68	2	69
69	2	78
70	2	77
71	2	76
72	2	75
73	2	74
74	2	83
75	2	82
76	2	81
77	2	80
78	2	79
79	2	88
80	2	87
81	2	86
82	2	85
83	2	84
84	2	92
85	2	91
86	2	90
87	2	89
88	2	97
89	2	96
90	2	95
91	2	94
92	2	93
93	2	102
94	2	101
95	2	100
96	2	99
97	2	98
98	6	107
99	6	106
100	6	105
101	6	104
102	6	103
103	2	112
104	2	111
105	2	110
106	2	109
107	2	108
108	2	117
109	2	116
110	2	115
111	2	114
112	2	113
113	2	122
114	2	121
115	2	120
116	2	119
117	2	118
118	2	127
119	2	126
120	2	125
121	2	124
122	2	123
123	2	132
124	2	131
125	2	130
126	2	129
127	2	128
128	2	137
129	2	136
130	2	135
131	2	134
132	2	133
133	2	142
134	2	141
135	2	140
136	2	139
137	2	138
138	2	147
139	2	146
140	2	145
141	2	144
142	2	143
143	2	152
144	2	151
145	2	150
146	2	149
147	2	148
148	2	156
149	2	155
150	2	154
151	2	153
152	2	161
153	2	160
154	2	159
155	2	158
156	2	157
157	2	166
158	2	165
159	2	164
160	2	163
161	2	162
162	2	171
163	2	170
164	2	169
165	2	168
166	2	167
167	2	176
168	2	175
169	2	174
170	2	173
171	2	172
172	2	181
173	2	180
174	2	179
175	2	178
176	2	177
\.


--
-- Name: app_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.app_users_id_seq', 3, true);


--
-- Name: archived_practice_tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.archived_practice_tasks_id_seq', 181, true);


--
-- Name: chat_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_messages_id_seq', 86, true);


--
-- Name: chat_rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_rooms_id_seq', 11, true);


--
-- Name: corrections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.corrections_id_seq', 1, false);


--
-- Name: daily_generated_tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.daily_generated_tasks_id_seq', 182, true);


--
-- Name: daily_tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.daily_tasks_id_seq', 1, false);


--
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sessions_id_seq', 1, false);


--
-- Name: user_progress_archive_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_progress_archive_id_seq', 176, true);


--
-- Name: user_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_progress_id_seq', 86, true);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: app_users app_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_users
    ADD CONSTRAINT app_users_pkey PRIMARY KEY (id);


--
-- Name: archived_practice_tasks archived_practice_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archived_practice_tasks
    ADD CONSTRAINT archived_practice_tasks_pkey PRIMARY KEY (id);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: chat_rooms chat_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_rooms
    ADD CONSTRAINT chat_rooms_pkey PRIMARY KEY (id);


--
-- Name: correction_theory correction_theory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.correction_theory
    ADD CONSTRAINT correction_theory_pkey PRIMARY KEY (type);


--
-- Name: corrections corrections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.corrections
    ADD CONSTRAINT corrections_pkey PRIMARY KEY (id);


--
-- Name: daily_generated_tasks daily_generated_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daily_generated_tasks
    ADD CONSTRAINT daily_generated_tasks_pkey PRIMARY KEY (id);


--
-- Name: daily_tasks daily_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daily_tasks
    ADD CONSTRAINT daily_tasks_pkey PRIMARY KEY (id);


--
-- Name: room_users room_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.room_users
    ADD CONSTRAINT room_users_pkey PRIMARY KEY ("userId", "roomId");


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: user_progress_archive user_progress_archive_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_progress_archive
    ADD CONSTRAINT user_progress_archive_pkey PRIMARY KEY (id);


--
-- Name: user_progress user_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_progress
    ADD CONSTRAINT user_progress_pkey PRIMARY KEY (id);


--
-- Name: app_users_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX app_users_email_key ON public.app_users USING btree (email);


--
-- Name: app_users_userTag_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "app_users_userTag_key" ON public.app_users USING btree ("userTag");


--
-- Name: archived_practice_tasks_userId_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "archived_practice_tasks_userId_date_idx" ON public.archived_practice_tasks USING btree ("userId", date);


--
-- Name: daily_generated_tasks_userId_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "daily_generated_tasks_userId_date_idx" ON public.daily_generated_tasks USING btree ("userId", date);


--
-- Name: user_progress_archive_archivedTaskId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "user_progress_archive_archivedTaskId_idx" ON public.user_progress_archive USING btree ("archivedTaskId");


--
-- Name: user_progress_archive_userProgressId_archivedTaskId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "user_progress_archive_userProgressId_archivedTaskId_key" ON public.user_progress_archive USING btree ("userProgressId", "archivedTaskId");


--
-- Name: user_progress_archive_userProgressId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "user_progress_archive_userProgressId_idx" ON public.user_progress_archive USING btree ("userProgressId");


--
-- Name: user_progress_userId_date_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "user_progress_userId_date_key" ON public.user_progress USING btree ("userId", date);


--
-- Name: archived_practice_tasks archived_practice_tasks_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archived_practice_tasks
    ADD CONSTRAINT "archived_practice_tasks_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.app_users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: chat_messages chat_messages_roomId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT "chat_messages_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES public.chat_rooms(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: chat_messages chat_messages_senderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT "chat_messages_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES public.app_users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: corrections corrections_messageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.corrections
    ADD CONSTRAINT "corrections_messageId_fkey" FOREIGN KEY ("messageId") REFERENCES public.chat_messages(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: daily_generated_tasks daily_generated_tasks_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daily_generated_tasks
    ADD CONSTRAINT "daily_generated_tasks_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.app_users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: daily_tasks daily_tasks_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daily_tasks
    ADD CONSTRAINT "daily_tasks_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.app_users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: room_users room_users_roomId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.room_users
    ADD CONSTRAINT "room_users_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES public.chat_rooms(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: room_users room_users_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.room_users
    ADD CONSTRAINT "room_users_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.app_users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sessions sessions_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT "sessions_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.app_users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: user_progress_archive user_progress_archive_archivedTaskId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_progress_archive
    ADD CONSTRAINT "user_progress_archive_archivedTaskId_fkey" FOREIGN KEY ("archivedTaskId") REFERENCES public.archived_practice_tasks(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: user_progress_archive user_progress_archive_userProgressId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_progress_archive
    ADD CONSTRAINT "user_progress_archive_userProgressId_fkey" FOREIGN KEY ("userProgressId") REFERENCES public.user_progress(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: user_progress user_progress_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_progress
    ADD CONSTRAINT "user_progress_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.app_users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

